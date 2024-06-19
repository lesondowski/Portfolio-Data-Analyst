CREATE TABLE `railway_2` (
  `Transaction_ID` text,
  `Date_of_Purchase` text,
  `Time_of_Purchase` text,
  `Purchase_Type` text,
  `Payment_Method` text,
  `Railcard` text,
  `Ticket_Class` text,
  `Ticket_Type` text,
  `Price` int DEFAULT NULL,
  `Departure_Station` text,
  `Arrival_Destination` text,
  `Date_of_Journey` text,
  `Departure_Time` text,
  `Arrival_Time` text,
  `Actual_Arrival_Time` text,
  `Journey_Status` text,
  `Reason_for_Delay` text,
  `Refund_Request` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `railway_copy` (
  `Transaction_ID` text,
  `Date_of_Purchase` text,
  `Time_of_Purchase` text,
  `Purchase_Type` text,
  `Payment_Method` text,
  `Railcard` text,
  `Ticket_Class` text,
  `Ticket_Type` text,
  `Price` int DEFAULT NULL,
  `Departure_Station` text,
  `Arrival_Destination` text,
  `Date_of_Journey` text,
  `Departure_Time` text,
  `Arrival_Time` text,
  `Actual_Arrival_Time` text,
  `Journey_Status` text,
  `Reason_for_Delay` text,
  `Refund_Request` text,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into railway_2 (select * from train_in_uk.railway); 
-- ----------------copy dataset-------------------


-- duplicated--------------------------------------
insert into train_in_uk.railway_copy
select *,
	row_number() over( partition by Transaction_ID,Date_of_Purchase,Time_of_Purchase,Payment_Method) as row_num
from train_in_uk.railway_2;
delete from train_in_uk.railway_copy where row_num > 1;
alter table railway_copy
drop row_num;


--  Fill in the missing value
select distinct Departure_Time from railway_copy;
select distinct Journey_Status from railway_copy;
select distinct Reason_for_Delay  from railway_copy;
select distinct Departure_Station from railway_copy;

update train_in_uk.railway_copy
set Reason_for_Delay = "None" where Reason_for_Delay = "";
update train_in_uk.railway_copy
set Actual_Arrival_Time = "no infor" where Journey_Status = "Cancelled";
update railway_copy
set Departure_Station = trim(Departure_Station);
update railway_copy
set Ticket_Class = trim(Ticket_Class);
update railway_copy
set Ticket_Type =trim(Ticket_Type);


-- từ file đã làm sạch, lưu vào file csv mới


alter table railway_copy modify Price varchar(6);


insert into railway_copy(Transaction_ID,Date_of_Purchase,Time_of_Purchase,Purchase_Type,Payment_Method,Railcard,Ticket_Class,Ticket_Type,
						Price,Departure_Station,Arrival_Destination,Date_of_Journey,Departure_Time,Arrival_Time,Actual_Arrival_Time,Journey_Status,
                        Reason_for_Delay,Refund_Request) 
			value ( "Transaction_ID","Date_of_Purchase","Time_of_Purchase","Purchase_Type","Payment_Method","Railcard","Ticket_Class","Ticket_Type",
					"Price","Departure_Station","Arrival_Destination","Date_of_Journey","Departure_Time","Arrival_Time","Actual_Arrival_Time",
                    "Journey_Status","Reason_for_Delay","Refund_Request"
					);

-- tạo nhãn cho tập dữ liệu
create table Railway_Cleaned as
select * from railway_copy 
where Transaction_ID = "Transaction_ID"
union ALL
select * from railway_copy
where Transaction_ID != "Transaction_ID"; 
-- đẩy nhãn lên đầu


-- gán vào file mới 
SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Railway_Cleaned.csv' -- địa chi lưu file 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM railway_Cleaned;
SHOW VARIABLES LIKE 'secure_file_priv'; -- xem nơi được lưu file 



