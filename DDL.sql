CREATE DATABASE HotelBookingSystem;
USE HotelBookingSystem;

CREATE TABLE Departments(
    Department_ID INT PRIMARY KEY AUTO_INCREMENT,
    Department_Name VARCHAR(50) NOT NULL UNIQUE,
    Location VARCHAR(100),
    Budget DECIMAL(12, 2)
);

CREATE TABLE Employees (
    Employee_ID INT PRIMARY KEY AUTO_INCREMENT,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Position VARCHAR(100) NOT NULL,
    Department_ID INT,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    Hire_Date DATE NOT NULL,
    Salary DECIMAL(8, 2) CHECK(Salary > 0),
    FOREIGN KEY (Department_ID) REFERENCES Departments(Department_ID) ON DELETE SET NULL
);

CREATE TABLE Guests (
    Guest_ID INT PRIMARY KEY AUTO_INCREMENT,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    National_ID VARCHAR(50) UNIQUE NOT NULL,
    Date_of_Birth DATE,
    Nationality VARCHAR(50),
    Address TEXT,
    Registration_Date DATE NOT NULL
);

CREATE TABLE Guests_Phones (
    Phone_ID INT PRIMARY KEY AUTO_INCREMENT,
    Guest_ID INT NOT NULL,
    Phone_Number VARCHAR(15) NOT NULL,
    Phone_Type VARCHAR(20) CHECK (Phone_Type IN ('Mobile', 'Home', 'Work', 'Other')),
    FOREIGN KEY (Guest_ID) REFERENCES Guests(Guest_ID) ON DELETE CASCADE
);


CREATE TABLE Room_Types (
    Room_Type_ID INT PRIMARY KEY AUTO_INCREMENT,
    Type_Name VARCHAR(30) NOT NULL UNIQUE,
    Description TEXT,
    Base_Price DECIMAL(8, 2) NOT NULL,
    Max_Occupancy INT NOT NULL,
    Bed_Type VARCHAR(30),
    Size_SQM DECIMAL(5, 2)
);

CREATE TABLE Rooms (
    Room_ID INT PRIMARY KEY AUTO_INCREMENT,
    Room_Number VARCHAR(10) NOT NULL UNIQUE,
    Room_Type_ID INT NOT NULL,
    Floor INT NOT NULL,
    Price_Per_Night DECIMAL(8, 2) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Available' CHECK (Status IN ('Available', 'Occupied', 'Maintenance', 'Reserved')),
    View_Type VARCHAR(30),
    Has_Balcony BOOLEAN DEFAULT FALSE,
    Last_Maintenance DATE,
    FOREIGN KEY (Room_Type_ID) REFERENCES Room_Types(Room_Type_ID) ON DELETE RESTRICT
);

CREATE TABLE Bookings (
    Booking_ID INT PRIMARY KEY AUTO_INCREMENT,
    Guest_ID INT NOT NULL,
    Room_ID INT NOT NULL,
    Employee_ID INT,
    Check_In_Date DATE NOT NULL,
    Check_Out_Date DATE NOT NULL,
    Number_of_Guests INT NOT NULL,
    Total_Price DECIMAL(10, 2) NOT NULL,
    Booking_Status VARCHAR(20) DEFAULT 'Confirmed' CHECK (Booking_Status IN ('Pending', 'Confirmed', 'Checked-In', 'Checked-Out', 'Cancelled')),
    Booking_Date DATETIME NOT NULL,
    Special_Requests TEXT,
    FOREIGN KEY (Guest_ID) REFERENCES Guests(Guest_ID) ON DELETE RESTRICT,
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID) ON DELETE RESTRICT,
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID) ON DELETE SET NULL,
    CHECK (Check_Out_Date > Check_In_Date)
);

CREATE TABLE Payments (
    Payment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Booking_ID INT NOT NULL,
    Payment_Date DATETIME NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Payment_Method VARCHAR(30) NOT NULL,
    Payment_Status VARCHAR(20) DEFAULT 'Pending' CHECK (Payment_Status IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    Transaction_ID VARCHAR(50) UNIQUE,
    Processed_By INT,
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID) ON DELETE RESTRICT,
    FOREIGN KEY (Processed_By) REFERENCES Employees(Employee_ID) ON DELETE SET NULL
);

CREATE TABLE Services (
    Service_ID INT PRIMARY KEY AUTO_INCREMENT,
    Service_Name VARCHAR(50) NOT NULL,
    Description TEXT,
    Price DECIMAL(6, 2) NOT NULL,
    Service_Type VARCHAR(30),
    Availability BOOLEAN DEFAULT TRUE
);

CREATE TABLE Booking_Services (
    Booking_Service_ID INT PRIMARY KEY AUTO_INCREMENT,
    Booking_ID INT NOT NULL,
    Service_ID INT NOT NULL,
    Service_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Quantity INT DEFAULT 1,
    Total_Cost DECIMAL(8, 2) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Requested' CHECK (Status IN ('Requested', 'Confirmed', 'Completed', 'Cancelled')),
    Notes TEXT,
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID) ON DELETE CASCADE,
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID) ON DELETE RESTRICT
);