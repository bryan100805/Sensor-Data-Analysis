USE GoBest_Cab;

DROP TABLE IF EXISTS Sensor_Data;
DROP TABLE IF EXISTS Safety_Labels;
DROP TABLE IF EXISTS Cab_Driver;

CREATE TABLE Cab_Driver (
    driver_id INT NOT NULL,
    driver_name VARCHAR(255) NOT NULL,
    data_of_birth VARCHAR(10) NOT NULL,
    No_of_Years_driving_exp INT NOT NULL,
    gender VARCHAR(6) NOT NULL,
    car_brand VARCHAR(255) NOT NULL,
    car_model_year DECIMAL(4,0) NOT NULL,
    driver_rating DECIMAL(2,1) NOT NULL,
	PRIMARY KEY(driver_id)
);

CREATE TABLE Safety_Labels (
	bookingID BIGINT NOT NULL,
	driver_id INT NOT NULL,
	label TINYINT NOT NULL,
	PRIMARY KEY(bookingID),
	FOREIGN KEY (driver_id)
	REFERENCES Cab_Driver(driver_id)
);

CREATE TABLE Sensor_Data (
	Sensor_ID INT IDENTITY(1,1) NOT NULL,
    bookingID BIGINT NOT NULL,
	Accuracy Float NULL,
	Bearing Float NULL,
	acceleration_x Float NULL,
	acceleration_y Float NULL,
	acceleration_z Float NULL,
	gyro_x Float NULL,
	gyro_y Float NULL,
	gyro_z Float NULL,
	second Float NULL,
	Speed Float NULL,
	PRIMARY KEY(Sensor_ID),
	FOREIGN KEY (bookingID)
	REFERENCES Safety_Labels(bookingID)
);