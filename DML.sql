INSERT INTO Departments (Department_Name, Location, Budget) VALUES
('Front Desk', 'Lobby - Floor 1', 50000.00),
('Housekeeping', 'Service Area - Floor B1', 75000.00),
('Food & Beverage', 'Restaurant - Floor 2', 100000.00),
('Maintenance', 'Technical Room - Floor B2', 60000.00),
('Management', 'Executive Suite - Floor 10', 120000.00);


INSERT INTO Employees (First_Name, Last_Name, Position, Department_ID, Email, Phone, Hire_Date, Salary) VALUES
('Sarah', 'Johnson', 'Front Desk Manager', 1, 'sarah.j@hotel.com', '555-0101', '2020-03-15', 45000.00),
('Michael', 'Chen', 'Receptionist', 1, 'michael.c@hotel.com', '555-0102', '2021-06-20', 35000.00),
('Maria', 'Garcia', 'Housekeeping Supervisor', 2, 'maria.g@hotel.com', '555-0103', '2019-01-10', 40000.00),
('James', 'Wilson', 'Maintenance Technician', 4, 'james.w@hotel.com', '555-0104', '2020-09-05', 42000.00),
('Emily', 'Brown', 'General Manager', 5, 'emily.b@hotel.com', '555-0105', '2018-05-01', 85000.00);


INSERT INTO Guests (First_Name, Last_Name, Email, Phone, National_ID, Date_of_Birth, Nationality, Address, Registration_Date) VALUES
('John', 'Smith', 'john.smith@email.com', '555-1001', 'US123456789', '1985-07-12', 'American', '123 Main St, New York, NY', '2024-01-15'),
('Emma', 'Davis', 'emma.davis@email.com', '207-946-0958', 'UK987654321', '1990-03-25', 'British', '45 Baker Street, London', '2024-02-20'),
('Ahmed', 'Hassan', 'ahmed.hassan@email.com', '212-345-678', 'EG555666777', '1988-11-08', 'Egyptian', '12 Tahrir Square, Cairo', '2024-03-10'),
('Sophie', 'Martin', 'sophie.martin@email.com', '142-868-200', 'FR111222333', '1992-05-18', 'French', '78 Champs-Elysees, Paris', '2024-04-05'),
('Hiroshi', 'Tanaka', 'hiroshi.tanaka@email.com', '354-321-000', 'JP888999000', '1987-09-30', 'Japanese', '5-1-1 Shibuya, Tokyo', '2024-05-12');


INSERT INTO Guests_Phones (Guest_ID, Phone_Number, Phone_Type) VALUES
(1, '555-1001', 'Mobile'),
(1, '555-1002', 'Work'),
(2, '207-946-0958', 'Mobile'),
(3, '212-345-678', 'Mobile'),
(3, '287-654-321', 'Home'),
(4, '142-868-200', 'Mobile'),
(5, '354-321-000', 'Mobile');


INSERT INTO Room_Types (Type_Name, Description, Base_Price, Max_Occupancy, Bed_Type, Size_SQM) VALUES
('Standard Single', 'Cozy room with single bed', 80.00, 1, 'Single', 20.00),
('Standard Double', 'Comfortable room with double bed', 120.00, 2, 'Queen', 25.00),
('Deluxe Suite', 'Spacious suite with living area', 250.00, 3, 'King', 45.00),
('Executive Suite', 'Luxury suite with city view', 400.00, 4, 'King', 60.00),
('Family Room', 'Large room for families', 180.00, 4, 'Two Queens', 40.00);


INSERT INTO Rooms (Room_Number, Room_Type_ID, Floor, Price_Per_Night, Status, View_Type, Has_Balcony, Last_Maintenance) VALUES
('101', 1, 1, 80.00, 'Available', 'Garden', FALSE, '2024-10-15'),
('205', 2, 2, 120.00, 'Occupied', 'City', FALSE, '2024-09-20'),
('308', 3, 3, 250.00, 'Available', 'Sea', TRUE, '2024-11-01'),
('510', 4, 5, 400.00, 'Reserved', 'Panoramic', TRUE, '2024-10-28'),
('412', 5, 4, 180.00, 'Available', 'Pool', TRUE, '2024-11-10'),
('203', 2, 2, 120.00, 'Maintenance', 'City', FALSE, '2024-11-20'),
('607', 3, 6, 250.00, 'Available', 'Sea', TRUE, '2024-10-05');


INSERT INTO Bookings (Guest_ID, Room_ID, Employee_ID, Check_In_Date, Check_Out_Date, Number_of_Guests, Total_Price, Booking_Status, Booking_Date, Special_Requests) VALUES
(1, 2, 2, '2024-11-20', '2024-11-25', 2, 600.00, 'Checked-In', '2024-11-15 10:30:00', 'Late check-in requested'),
(2, 4, 1, '2024-12-01', '2024-12-05', 2, 1600.00, 'Confirmed', '2024-11-18 14:20:00', 'High floor, champagne'),
(3, 5, 2, '2024-11-28', '2024-12-02', 4, 900.00, 'Confirmed', '2024-11-19 09:15:00', 'Extra towels and baby cot'),
(4, 3, 1, '2024-11-22', '2024-11-24', 2, 500.00, 'Checked-Out', '2024-11-10 16:45:00', 'Quiet room please'),
(5, 1, 2, '2024-12-10', '2024-12-15', 1, 400.00, 'Confirmed', '2024-11-21 11:00:00', 'Non-smoking room');


INSERT INTO Payments (Booking_ID, Payment_Date, Amount, Payment_Method, Payment_Status, Transaction_ID, Processed_By) VALUES
(1, '2024-11-20 15:30:00', 600.00, 'Credit Card', 'Completed', 'TXN001234567', 2),
(2, '2024-11-18 14:25:00', 800.00, 'Credit Card', 'Completed', 'TXN001234568', 1),
(3, '2024-11-19 09:20:00', 450.00, 'Debit Card', 'Completed', 'TXN001234569', 2),
(4, '2024-11-24 11:00:00', 500.00, 'Cash', 'Completed', 'TXN001234570', 1),
(5, '2024-11-21 11:05:00', 200.00, 'Online', 'Completed', 'TXN001234571', 2);


INSERT INTO Services (Service_Name, Description, Price, Service_Type, Availability) VALUES
('Room Service Breakfast', 'Breakfast delivered to room', 25.00, 'Food & Beverage', TRUE),
('Laundry Service', 'Same-day laundry service', 30.00, 'Housekeeping', TRUE),
('Airport Transfer', 'Car service to/from airport', 50.00, 'Transportation', TRUE),
('Spa Package', '60-min massage and facial', 120.00, 'Wellness', TRUE),
('Late Checkout', 'Extended checkout to 3 PM', 40.00, 'Front Desk', TRUE);


INSERT INTO Booking_Services (Booking_ID, Service_ID, Service_Date, Quantity, Total_Cost, Status, Notes) VALUES
(1, 1, '2024-11-21 08:00:00', 2, 50.00, 'Completed', 'Delivered at 8:15 AM'),
(1, 2, '2024-11-22 10:00:00', 1, 30.00, 'Completed', 'Picked up at 10 AM'),
(2, 3, '2024-12-01 14:00:00', 1, 50.00, 'Confirmed', 'Pickup at terminal 3'),
(2, 4, '2024-12-02 15:00:00', 1, 120.00, 'Confirmed', 'Preferred therapist: Maria'),
(3, 1, '2024-11-29 07:30:00', 4, 100.00, 'Requested', 'Two adult, two kids meals'),
(4, 5, '2024-11-24 12:00:00', 1, 40.00, 'Completed', 'Checkout extended to 3 PM');