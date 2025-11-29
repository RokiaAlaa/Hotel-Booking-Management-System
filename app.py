from flask import Flask, render_template, request, jsonify, session
import mysql.connector
from mysql.connector import Error
from datetime import datetime
from decimal import Decimal

app = Flask(__name__)

# 🔐 مفتاح سري للـ Session
app.secret_key = 'hotel-secret-key-12345'

# 🔑 الباسورد الثابت لعرض الحجوزات
BOOKINGS_PASSWORD = '12345'

# ===== إعدادات قاعدة البيانات =====
DB_CONFIG = {
    'host': 'localhost',
    'port': 3307,
    'database': 'HotelBookingSystem',
    'user': 'root',
    'password': ''
}

# ===== دالة الاتصال بقاعدة البيانات =====
def get_db_connection():
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"❌ خطأ في الاتصال: {e}")
        return None

# ===== الصفحة الرئيسية =====
@app.route('/')
def index():
    """عرض الصفحة الرئيسية مع بيانات الغرف"""
    connection = get_db_connection()
    if not connection:
        return "خطأ في الاتصال بقاعدة البيانات", 500
    
    cursor = connection.cursor(dictionary=True)
    
    query = """
        SELECT 
            r.Room_ID,
            r.Room_Number,
            rt.Type_Name,
            rt.Description,
            r.Price_Per_Night,
            r.Status,
            rt.Max_Occupancy,
            rt.Size_SQM,
            r.View_Type
        FROM Rooms r
        JOIN Room_Types rt ON r.Room_Type_ID = rt.Room_Type_ID
        WHERE r.Status = 'Available'
        LIMIT 3
    """
    
    cursor.execute(query)
    rooms = cursor.fetchall()
    
    cursor.close()
    connection.close()
    
    return render_template('index.html', rooms=rooms)

# ===== API: التحقق من الباسورد =====
@app.route('/api/verify-password', methods=['POST'])
def verify_password():
    """التحقق من الباسورد وإرجاع الحجوزات مباشرة"""
    data = request.json
    password = data.get('password', '')
    
    if password != BOOKINGS_PASSWORD:
        return jsonify({'success': False, 'error': 'كلمة المرور غير صحيحة'})
    
    # جلب الحجوزات
    connection = get_db_connection()
    if not connection:
        return jsonify({'success': False, 'error': 'خطأ في الاتصال'}), 500
    
    cursor = connection.cursor(dictionary=True)
    
    query = """
        SELECT 
            b.Booking_ID,
            CONCAT(g.First_Name, ' ', g.Last_Name) as Guest_Name,
            g.Email,
            gp.Phone_Number as Phone,
            r.Room_Number,
            rt.Type_Name,
            b.Check_In_Date,
            b.Check_Out_Date,
            b.Number_of_Guests,
            b.Total_Price,
            b.Booking_Status,
            b.Special_Requests,
            CONCAT(e.First_Name, ' ', e.Last_Name) as Employee_Name
        FROM Bookings b
        JOIN Guests g ON b.Guest_ID = g.Guest_ID
        LEFT JOIN Guests_Phones gp ON g.Guest_ID = gp.Guest_ID
        JOIN Rooms r ON b.Room_ID = r.Room_ID
        JOIN Room_Types rt ON r.Room_Type_ID = rt.Room_Type_ID
        JOIN Employees e ON b.Employee_ID = e.Employee_ID
        GROUP BY b.Booking_ID
        ORDER BY b.Booking_Date DESC
    """
    
    cursor.execute(query)
    all_bookings = cursor.fetchall()
    
    for booking in all_bookings:
        booking['Check_In_Date'] = booking['Check_In_Date'].strftime('%Y-%m-%d')
        booking['Check_Out_Date'] = booking['Check_Out_Date'].strftime('%Y-%m-%d')
    
    cursor.close()
    connection.close()
    
    return jsonify({'success': True, 'bookings': all_bookings})

# ===== صفحة الحجوزات (محمية بباسورد) =====
@app.route('/bookings')
def bookings():
    """عرض صفحة الباسورد دائماً - لا توجد Session"""
    return render_template('bookings_password.html')


# ===== صفحة الغرف =====
@app.route('/rooms')
def rooms():
    """عرض جميع الغرف"""
    connection = get_db_connection()
    if not connection:
        return "خطأ في الاتصال بقاعدة البيانات", 500
    
    cursor = connection.cursor(dictionary=True)
    
    query = """
        SELECT 
            r.Room_ID,
            r.Room_Number,
            r.Floor,
            r.Price_Per_Night,
            r.Status,
            r.View_Type,
            r.Has_Balcony,
            rt.Type_Name,
            rt.Description,
            rt.Max_Occupancy,
            rt.Bed_Type,
            rt.Size_SQM
        FROM Rooms r
        JOIN Room_Types rt ON r.Room_Type_ID = rt.Room_Type_ID
        ORDER BY r.Floor, r.Room_Number
    """
    
    cursor.execute(query)
    all_rooms = cursor.fetchall()
    
    cursor.close()
    connection.close()
    
    return render_template('rooms.html', rooms=all_rooms)

# ===== 1️⃣ صفحة الاختيار: عميل جديد أم موجود =====
@app.route('/book-start')
def book_choice():
    """صفحة الاختيار بين عميل جديد أو موجود"""
    return render_template('book_choice.html')

# ===== 2️⃣ صفحة تسجيل عميل جديد =====
@app.route('/book/register')
def register_guest():
    """صفحة تسجيل عميل جديد"""
    return render_template('book.html')

# ===== 3️⃣ صفحة الحجز مع عميل موجود =====
@app.route('/book')
def book_with_guest():
    """صفحة إنشاء حجز جديد مع عميل موجود"""
    guest_id = request.args.get('guest_id', type=int)
    
    connection = get_db_connection()
    if not connection:
        return "خطأ في الاتصال بقاعدة البيانات", 500
    
    cursor = connection.cursor(dictionary=True)
    
    # جلب بيانات العميل
    guest = None
    if guest_id:
        cursor.execute("""
            SELECT Guest_ID, CONCAT(First_Name, ' ', Last_Name) as Name, 
                   Email, Phone, Address
            FROM Guests 
            WHERE Guest_ID = %s
        """, (guest_id,))
        guest = cursor.fetchone()
    
    # جلب الغرف المتاحة
    cursor.execute("""
        SELECT r.Room_ID, r.Room_Number, rt.Type_Name, r.Price_Per_Night, rt.Max_Occupancy
        FROM Rooms r
        JOIN Room_Types rt ON r.Room_Type_ID = rt.Room_Type_ID
        WHERE r.Status = 'Available'
        ORDER BY r.Room_Number
    """)
    rooms = cursor.fetchall()
    
    # جلب الخدمات المتاحة
    cursor.execute("""
        SELECT Service_ID, Service_Name, Description, Price, Service_Type
        FROM Services
        WHERE Availability = TRUE
        ORDER BY Service_Type, Service_Name
    """)
    services = cursor.fetchall()
    
    cursor.close()
    connection.close()
    
    return render_template('create_booking.html', 
                          guest=guest, 
                          rooms=rooms, 
                          services=services)

# ===== API: جلب جميع الضيوف =====
@app.route('/api/guests')
def api_guests():
    """API لجلب جميع الضيوف"""
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'خطأ في الاتصال'}), 500
    
    cursor = connection.cursor(dictionary=True)
    cursor.execute("""
        SELECT g.Guest_ID, g.First_Name, g.Last_Name, g.Email,
               GROUP_CONCAT(gp.Phone_Number) as Phone
        FROM Guests g
        LEFT JOIN Guests_Phones gp ON g.Guest_ID = gp.Guest_ID
        GROUP BY g.Guest_ID
        ORDER BY g.Registration_Date DESC
    """)
    guests = cursor.fetchall()
    
    for guest in guests:
        if guest.get('Date_of_Birth'):
            guest['Date_of_Birth'] = guest['Date_of_Birth'].strftime('%Y-%m-%d')
        if guest.get('Registration_Date'):
            guest['Registration_Date'] = guest['Registration_Date'].strftime('%Y-%m-%d')
    
    cursor.close()
    connection.close()
    
    return jsonify(guests)

# ===== API: جلب الغرف المتاحة =====
@app.route('/api/available-rooms')
def api_available_rooms():
    """API لجلب الغرف المتاحة"""
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'خطأ في الاتصال'}), 500
    
    cursor = connection.cursor(dictionary=True)
    
    query = """
        SELECT 
            r.Room_ID,
            r.Room_Number,
            rt.Type_Name,
            r.Price_Per_Night,
            rt.Max_Occupancy,
            r.View_Type
        FROM Rooms r
        JOIN Room_Types rt ON r.Room_Type_ID = rt.Room_Type_ID
        WHERE r.Status = 'Available'
    """
    
    cursor.execute(query)
    rooms = cursor.fetchall()
    
    cursor.close()
    connection.close()
    
    return jsonify(rooms)

# ===== API: إضافة عميل جديد =====
@app.route('/api/guests/add', methods=['POST'])
def add_guest():
    """إضافة عميل جديد مع أرقام التليفونات"""
    data = request.json
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'success': False, 'error': 'خطأ في الاتصال'}), 500
    
    cursor = connection.cursor()
    
    try:
        # 1️⃣ إضافة العميل في جدول Guests
        guest_query = """
            INSERT INTO Guests 
            (First_Name, Last_Name, Email, National_ID, Date_of_Birth, 
             Nationality, Address, Registration_Date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        guest_values = (
            data['first_name'],
            data['last_name'],
            data['email'],
            data['national_id'],
            data.get('date_of_birth'),
            data.get('nationality'),
            data.get('address'),
            data['registration_date']
        )
        
        cursor.execute(guest_query, guest_values)
        guest_id = cursor.lastrowid
        
        # 2️⃣ إضافة أرقام التليفونات
        phones = data.get('phones', [])
        
        if phones:
            phone_query = """
                INSERT INTO Guests_Phones (Guest_ID, Phone_Number, Phone_Type)
                VALUES (%s, %s, %s)
            """
            
            for phone in phones:
                cursor.execute(phone_query, (
                    guest_id,
                    phone['number'],
                    phone.get('type', 'Mobile')
                ))
        
        connection.commit()
        cursor.close()
        connection.close()
        
        return jsonify({
            'success': True,
            'guest_id': guest_id,
            'message': 'تم إضافة العميل بنجاح'
        })
        
    except mysql.connector.IntegrityError as e:
        connection.rollback()
        cursor.close()
        connection.close()
        
        if 'Email' in str(e):
            return jsonify({'success': False, 'error': 'البريد الإلكتروني مستخدم من قبل'}), 400
        elif 'National_ID' in str(e):
            return jsonify({'success': False, 'error': 'الرقم القومي مستخدم من قبل'}), 400
        else:
            return jsonify({'success': False, 'error': 'خطأ في البيانات المدخلة'}), 400
            
    except Error as e:
        connection.rollback()
        cursor.close()
        connection.close()
        return jsonify({'success': False, 'error': str(e)}), 500

# ===== API: إنشاء حجز كامل =====
@app.route('/api/bookings/create-full', methods=['POST'])
def create_full_booking():
    """إنشاء حجز كامل مع الخدمات والدفع"""
    data = request.json
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'success': False, 'error': 'خطأ في الاتصال'}), 500
    
    cursor = connection.cursor()
    
    try:
        # حساب السعر
        checkin = datetime.strptime(data['checkin'], '%Y-%m-%d')
        checkout = datetime.strptime(data['checkout'], '%Y-%m-%d')
        nights = (checkout - checkin).days
        
        cursor.execute("SELECT Price_Per_Night FROM Rooms WHERE Room_ID = %s", 
                      (data['room_id'],))
        room = cursor.fetchone()
        room_total = Decimal(str(room[0])) * Decimal(str(nights))
        
        services_total = Decimal('0.00')
        for service in data.get('services', []):
            service_price = Decimal(str(service['price']))
            service_qty = Decimal(str(service['quantity']))
            services_total += service_price * service_qty
        
        total_price = room_total + services_total
        
        # إدخال الحجز
        booking_query = """
            INSERT INTO Bookings 
            (Guest_ID, Room_ID, Employee_ID, Check_In_Date, Check_Out_Date, 
             Number_of_Guests, Total_Price, Booking_Status, Booking_Date, Special_Requests)
            VALUES (%s, %s, 1, %s, %s, %s, %s, 'Confirmed', NOW(), %s)
        """
        
        booking_values = (
            data['guest_id'],
            data['room_id'],
            data['checkin'],
            data['checkout'],
            data['guests'],
            total_price,
            data.get('special_requests', '')
        )
        
        cursor.execute(booking_query, booking_values)
        connection.commit()
        booking_id = cursor.lastrowid
        
        # إدخال الخدمات
        if data.get('services'):
            for service in data['services']:
                service_query = """
                    INSERT INTO Booking_Services 
                    (Booking_ID, Service_ID, Quantity, Total_Cost, Status)
                    VALUES (%s, %s, %s, %s, 'Confirmed')
                """
                service_total = Decimal(str(service['price'])) * Decimal(str(service['quantity']))
                service_values = (
                    booking_id,
                    service['service_id'],
                    service['quantity'],
                    service_total
                )
                cursor.execute(service_query, service_values)
        
        # إدخال الدفع
        payment_query = """
            INSERT INTO Payments 
            (Booking_ID, Payment_Date, Amount, Payment_Method, 
             Payment_Status, Transaction_ID, Processed_By)
            VALUES (%s, NOW(), %s, %s, %s, %s, 1)
        """
        
        transaction_id = f"TXN-{booking_id}-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        payment_values = (
            booking_id,
            data['payment_amount'],
            data['payment_method'],
            'Completed',  # ✅ Payment Status
            transaction_id  # ✅ Transaction ID
        )
        
        cursor.execute(payment_query, payment_values)
        connection.commit()
        payment_id = cursor.lastrowid
        
        # تحديث حالة الغرفة
        cursor.execute("UPDATE Rooms SET Status = 'Reserved' WHERE Room_ID = %s", 
                      (data['room_id'],))
        connection.commit()
        
        cursor.close()
        connection.close()
        
        return jsonify({
            'success': True,
            'booking_id': booking_id,
            'payment_id': payment_id,
            'transaction_id': transaction_id,
            'total_price': float(total_price),
            'room_total': float(room_total),
            'services_total': float(services_total)
        })
        
    except Error as e:
        connection.rollback()
        cursor.close()
        connection.close()
        return jsonify({'success': False, 'error': str(e)}), 500

# ===== API: حذف حجز =====
@app.route('/api/bookings/delete/<int:booking_id>', methods=['DELETE'])
def delete_booking(booking_id):
    """حذف حجز"""
    connection = get_db_connection()
    if not connection:
        return jsonify({'success': False, 'error': 'خطأ في الاتصال'}), 500
    
    cursor = connection.cursor()
    
    try:
        cursor.execute("SELECT Room_ID FROM Bookings WHERE Booking_ID = %s", (booking_id,))
        room = cursor.fetchone()
        
        cursor.execute("DELETE FROM Bookings WHERE Booking_ID = %s", (booking_id,))
        
        if room:
            cursor.execute("UPDATE Rooms SET Status = 'Available' WHERE Room_ID = %s", (room[0],))
        
        connection.commit()
        cursor.close()
        connection.close()
        
        return jsonify({'success': True})
        
    except Error as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ===== API: تحديث حالة الحجز =====
@app.route('/api/bookings/update-status/<int:booking_id>', methods=['PUT'])
def update_booking_status(booking_id):
    """تحديث حالة الحجز"""
    data = request.json
    new_status = data.get('status')
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'success': False, 'error': 'خطأ في الاتصال'}), 500
    
    cursor = connection.cursor()
    
    try:
        cursor.execute(
            "UPDATE Bookings SET Booking_Status = %s WHERE Booking_ID = %s",
            (new_status, booking_id)
        )
        connection.commit()
        
        if new_status == 'Checked-In':
            cursor.execute("""
                UPDATE Rooms r
                JOIN Bookings b ON r.Room_ID = b.Room_ID
                SET r.Status = 'Occupied'
                WHERE b.Booking_ID = %s
            """, (booking_id,))
        elif new_status == 'Completed':
            cursor.execute("""
                UPDATE Rooms r
                JOIN Bookings b ON r.Room_ID = b.Room_ID
                SET r.Status = 'Available'
                WHERE b.Booking_ID = %s
            """, (booking_id,))
        
        connection.commit()
        cursor.close()
        connection.close()
        
        return jsonify({'success': True})
        
    except Error as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ===== API: إحصائيات الفندق =====
@app.route('/api/stats')
def api_stats():
    """جلب إحصائيات الفندق"""
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'خطأ في الاتصال'}), 500
    
    cursor = connection.cursor(dictionary=True)
    
    stats = {}
    
    cursor.execute("SELECT COUNT(*) as total FROM Guests")
    stats['total_guests'] = cursor.fetchone()['total']
    
    cursor.execute("SELECT COUNT(*) as total FROM Bookings WHERE Booking_Status = 'Confirmed'")
    stats['active_bookings'] = cursor.fetchone()['total']
    
    cursor.execute("SELECT COUNT(*) as total FROM Rooms WHERE Status = 'Available'")
    stats['available_rooms'] = cursor.fetchone()['total']
    
    cursor.execute("""
        SELECT COALESCE(SUM(Amount), 0) as total 
        FROM Payments 
        WHERE DATE(Payment_Date) = CURDATE()
    """)
    stats['today_revenue'] = float(cursor.fetchone()['total'])
    
    cursor.close()
    connection.close()
    
    return jsonify(stats)

# ===== تشغيل التطبيق =====
if __name__ == '__main__':
    print("=" * 50)
    print("🏨 فندق الهضبة - El Hadabah Hotel")
    print("🔒 صفحة الحجوزات محمية بباسورد: 12345")
    print("=" * 50)
    print("✅ السيرفر شغال على: http://127.0.0.1:5000")
    print("=" * 50)
    app.run(debug=True)
