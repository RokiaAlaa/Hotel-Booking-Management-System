-- TRANSACTION 1: BOOKING CREATION

-- 1. Check if guest exists
SELECT * FROM Guests 
WHERE Guest_ID = 3;

-- 2. Check room status and avalibility
SELECT Status
FROM Rooms
WHERE Room_ID = 7 AND status = 'Available';

-- 3. Check for overlapping bookings
SELECT Booking_ID, Check_In_Date, Check_Out_Date
FROM Bookings
WHERE Room_ID = 7 
AND NOT (Check_Out_Date <= '2024-12-05' OR Check_In_Date >= '2024-12-10');

-- 4. Insert a new booking
INSERT INTO Bookings
(Guest_ID, Room_ID, Employee_ID, Check_In_Date, Check_Out_Date,
 Number_of_Guests, Total_Price, Booking_Status, Booking_Date)
 VALUES (3, 7, 2, '2024-12-05', '2024-12-10', 2, 1250, 'Confirmed', NOW());

-- 5. Update rooms status
UPDATE Rooms 
SET Status = 'Reserved' 
WHERE Room_ID = 7;


-- TRANSACTION 2: CHECK-IN

-- 1. Select booking for update
SELECT * FROM Bookings 
WHERE Booking_ID = 2 AND Booking_Status = 'Confirmed';

-- 2. Check room status
SELECT Room_ID, Room_Number, Status
FROM Rooms
WHERE Room_ID = (SELECT Room_ID FROM Bookings WHERE Booking_ID = 2);

-- 3. Verify payments
SELECT Booking_ID, SUM(Amount) AS Total_Paid
FROM Payments
WHERE Booking_ID = 2 AND Payment_Status = 'Completed'
GROUP BY Booking_ID;

-- 4. Update booking status to Checked-In
UPDATE Bookings 
SET Booking_Status = 'Checked-In' 
WHERE Booking_ID = 2;

-- 5. Update room status to Occupied
UPDATE Rooms 
SET Status = 'Occupied' 
WHERE Room_ID = (SELECT Room_ID FROM Bookings WHERE Booking_ID = 2);


-- TRANSACTION 3: CHECK-OUT

-- 1. Select booking for update
SELECT * FROM Bookings 
WHERE Booking_ID = 1;

-- 2. Calculate services total
SELECT SUM(Total_Cost) FROM Booking_Services
WHERE Booking_ID = 1;

-- 3. Verify payment coverage
SELECT SUM(Amount) FROM Payments WHERE Booking_ID = 1;

-- 4. Update booking
UPDATE Bookings SET Booking_Status = 'Checked-Out' WHERE Booking_ID = 1;

-- 5. Update room
UPDATE Rooms SET Status = 'Available' WHERE Room_ID = 2;


-- TRANSACTION 4: CANCEL BOOKING

-- 1. Select booking for updates
SELECT * FROM Bookings
WHERE Booking_ID = 5;

-- 2. Update booking status -> cancelled
UPDATE Bookings
SET Booking_Status = 'Cancelled'
WHERE Booking_ID = 5;

-- 3. Check if other active bookings exist
SELECT COUNT(*) as Active_Bookings 
FROM Bookings 
WHERE Room_ID = (SELECT Room_ID FROM Bookings WHERE Booking_ID = 5)
  AND Booking_Status IN ('Confirmed', 'Checked-In', 'Reserved')
  AND Booking_ID != 5;
  
-- 4. If no active booking update room status -> available
UPDATE Rooms 
SET Status = 'Available' 
WHERE Room_ID = (SELECT Room_ID FROM Bookings WHERE Booking_ID = 5)
  AND NOT EXISTS (
      SELECT 1 FROM Bookings 
      WHERE Room_ID = Rooms.Room_ID 
        AND Booking_Status IN ('Confirmed', 'Checked-In', 'Reserved')
  );
  
-- 5. Refund payment
UPDATE Payments 
SET Payment_Status = 'Refunded' 
WHERE Booking_ID = 5 AND Payment_Status = 'Completed';


-- TRANSACTION 5: ADD SERVICE TO BOOKING

-- 1. Select booking for updates
SELECT * FROM Bookings
WHERE Booking_ID = 3;

-- 2. Read service info
SELECT Service_ID, Service_Name, Price, Availability
FROM Services
WHERE Service_ID = 4 AND Availability = TRUE;

-- 3. Insert new booking services
INSERT INTO Booking_Services 
(Booking_ID, Service_ID, Quantity, Total_Cost, Status)
VALUES (3, 4, 1, 120, 'Requested');

-- 4. Update Total_Price
UPDATE Bookings
SET Total_Price = Total_Price + 120
WHERE Booking_ID = 3;

-- TRANSACTION 6: PROCESS PAYMENT

-- 1. Lock booking and get total
SELECT Booking_ID, Guest_ID, Total_Price, Booking_Status 
FROM Bookings 
WHERE Booking_ID = 5;

-- 2. Insert payment record
INSERT INTO Payments 
    (Booking_ID, Payment_Date, Amount,
    Payment_Method, Payment_Status, Transaction_ID)
VALUES (5, NOW(), 200, 'Cash', 'Completed', 'TXN_NEW_001');

-- 3. Check if Paid >= Total_Price 
SELECT 
    (SELECT Total_Price FROM Bookings WHERE Booking_ID = 5) AS Total_Price,
    SUM(Amount) AS Total_Paid
FROM Payments
WHERE Booking_ID = 5 AND Payment_Status = 'Completed';
  
-- 4. Mark booking payment status -> Paid
UPDATE Bookings
SET Booking_Status = 'Confirmed'
WHERE Booking_ID = 5;

-- TRANSACTION 7: UPDATE ROOM STATUS

-- 1. Select room to update
SELECT Room_ID, Room_Number, Status, Last_Maintenance 
FROM Rooms 
WHERE Room_ID = 6;

-- 2. Check active overlapping bookings
SELECT COUNT(*) AS Active_Bookings
FROM Bookings
WHERE Room_ID = 6 AND Booking_Status IN ('Confirmed', 'Checked-In');

-- 3. Update room status (if safe)
UPDATE Rooms
SET Status = 'Maintenance'
WHERE Room_ID = 6;
