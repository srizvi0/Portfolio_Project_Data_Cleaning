/*

Filtering & Cleaning up housing data through SQL

*/

-- Viewing Housing DataSet

SELECT * FROM Housing_Data.dbo.Nashville_Housing;

-- Standardize Date Format
-- Add New Column for Date_Converted
-- Update "Date_Converted" Column with Convert Date

/*
Syntax: CONVERT(Target_Data_Type, Column_Name)

*/

ALTER TABLE Housing_Data.dbo.Nashville_Housing
ADD SALE_DATE_CONVERTED DATE;

UPDATE Housing_Data.dbo.Nashville_Housing
SET SALE_DATE_CONVERTED = CONVERT (Date, SaleDate);

SELECT SaleDate, SALE_DATE_CONVERTED FROM Housing_Data.dbo.Nashville_Housing;

-- Populate Property Address data for Null Values
-- ISNULL Function used to replace NULL values with replacement value

/*
Syntax: ISNULL(expression, replacement_value)
*/

SELECT A.parcelID, A.PropertyAddress, B.parcelID, B.PropertyAddress,
ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Housing_Data.dbo.Nashville_Housing A
JOIN Housing_Data.dbo.Nashville_Housing B
ON A.parcelID = B.parcelID AND A.uniqueID <> B.uniqueID;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Housing_Data.dbo.Nashville_Housing A
JOIN Housing_Data.dbo.Nashville_Housing B
ON A.parcelID = B.parcelID AND A.uniqueID <> B.uniqueID
WHERE A.PropertyAddress = NULL;

-- Breaking out Address into Indivisual Columns (Address, City, State)
-- Substring is used to extract portion of string on starting position and length

/*
Syntax: SUBSTRING(expression/column, start (1), length)
*/

-- CHARINDEX is used to find position (index) of substring within string

/*
Syntax: CHARINDEX(substring, string, [start_position]/Optional)
*/

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, -- CHARINDEX returns number 
SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN (PropertyAddress)) AS City
FROM Housing_Data.dbo.Nashville_Housing;

ALTER TABLE Housing_Data.dbo.Nashville_Housing
ADD Property_Split_Address nvarchar(250);

ALTER TABLE Housing_Data.dbo.Nashville_Housing
ADD Property_Split_City nvarchar(30);

UPDATE Housing_Data.dbo.Nashville_Housing
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

UPDATE Housing_Data.dbo.Nashville_Housing
SET Property_Split_City = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN (PropertyAddress));


-- Spliting Owner Address (ParseNAME Function)
-- ParseName is used to extract parts of object name, specifically looks for periods in sentence

/*
Synatx: PARSENAME('object_name'/Column Name, part [1..6])
*/

-- Replace function is use to replace specific substring with another substring

/*
REPLACE(string_expression, search_string, replacement_string)
*/

SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'), 3),
PARSENAME (REPLACE(OwnerAddress,',','.'), 2),
PARSENAME (REPLACE(OwnerAddress,',','.'), 1)
FROM Housing_Data.dbo.Nashville_Housing;

ALTER TABLE Housing_Data.dbo.Nashville_Housing
ADD Owner_Address nvarchar(250);

ALTER TABLE Housing_Data.dbo.Nashville_Housing
ADD Owner_City nvarchar(30);

ALTER TABLE Housing_Data.dbo.Nashville_Housing
ADD Owner_State nvarchar(250);

UPDATE Housing_Data.dbo.Nashville_Housing
SET Owner_Address = PARSENAME (REPLACE(OwnerAddress,',','.'), 3);

UPDATE Housing_Data.dbo.Nashville_Housing
SET Owner_City = PARSENAME (REPLACE(OwnerAddress,',','.'), 2);

UPDATE Housing_Data.dbo.Nashville_Housing
SET Owner_State = PARSENAME (REPLACE(OwnerAddress,',','.'), 1);

-- Chnage Y and N to Yes & No in 'Sold as Vacant' field

SELECT DISTINCT(SoldASVacant),
CASE
when SoldASVacant = 'Y' THEN 'Yes'
when SoldASVacant = 'N' THEN 'No'
ELSE SoldASVacant
END
FROM Housing_Data.dbo.Nashville_Housing;


UPDATE Housing_Data.dbo.Nashville_Housing
SET SoldASVacant = CASE
when SoldASVacant = 'Y' THEN 'Yes'
when SoldASVacant = 'N' THEN 'No'
ELSE SoldASVacant
END;


-- Remove Duplicates (CTE)
-- Row_num > 1 tells you the duplicates in the dataset


WITH ROWNUMCTE AS(

SELECT *,  
ROW_NUMBER() OVER 
(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS Row_num
FROM Housing_Data.dbo.Nashville_Housing 
)

DELETE FROM ROWNUMCTE
WHERE Row_num > 1;


-- Delete Unused Columns

ALTER TABLE Housing_Data.dbo.Nashville_Housing 
DROP COLUMN TaxDistrict;