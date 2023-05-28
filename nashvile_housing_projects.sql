--SELECTING EVERYTHING FROM THE TABLE
SELECT *
FROM HousingData..NashvileHousing;

--Converting the date to proper format

SELECT SaleDate, CONVERT(Date,SaleDate) AS Sale_Date
FROM HousingData..NashvileHousing;

ALTER Table HousingData..NashvileHousing
ADD SaleDateConverted Date;

UPDATE HousingData..NashvileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Filling Property Address by checking self join [If parcel id is same butnot have property address fill it with respective]

SELECT N.ParcelID,N.PropertyAddress,H.ParcelID,H.PropertyAddress
FROM HousingData..NashvileHousing N
JOIN HousingData..NashvileHousing H
ON N.ParcelID = H.ParcelID and N.UniqueID <> H.UniqueID;

UPDATE N
SET PropertyAddress = ISNULL(N.PropertyAddress,H.PropertyAddress)
FROM HousingData..NashvileHousing N
JOIN HousingData..NashvileHousing H
ON N.ParcelID = H.ParcelID and N.UniqueID <> H.UniqueID;

--Property Address spliting into city and address 

ALTER Table HousingData..NashvileHousing
ADD PropertySplit_Address NVARCHAR(255),

UPDATE HousingData..NashvileHousing
SET PropertySplit_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER Table HousingData..NashvileHousing
ADD PropertySplit_City NVARCHAR(255)

UPDATE HousingData..NashvileHousing
SET PropertySplit_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress))

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS "PropertySplit_Address",
REPLACE(PropertyAddress, ',','.')
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress)) AS "Property_Split_City"
FROM HousingData..NashvileHousing 

--Spliting using PARSENAME Method Easy try this 

SELECT
PARSENAME(REPLACE(PropertyAddress, ',','.'),1) AS Property_Split_City,
PARSENAME(REPLACE(PropertyAddress, ',','.'),2) AS Property_Split_Address
FROM HousingData..NashvileHousing 


--Spliting Owner Address

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) AS Owner_Split_Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'),2) AS Owner_Split_City,
PARSENAME(REPLACE(OwnerAddress, ',','.'),1) AS Owner_Split_State
FROM HousingData..NashvileHousing 

ALTER TABLE HousingData..NashvileHousing 
ADD Owner_Split_Address nvarchar(255);

UPDATE HousingData..NashvileHousing
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


ALTER TABLE HousingData..NashvileHousing 
ADD Owner_Split_City nvarchar(255);

UPDATE HousingData..NashvileHousing
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE HousingData..NashvileHousing 
ADD Owner_Split_State nvarchar(255)

UPDATE HousingData..NashvileHousing
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


--Spliting Property Address

ALTER Table HousingData..NashvileHousing
ADD PropertySplit_City NVARCHAR(255)

UPDATE HousingData..NashvileHousing
SET PropertySplit_City = PARSENAME(REPLACE(PropertyAddress, ',','.'),1)

ALTER Table HousingData..NashvileHousing
ADD PropertySplit_Address NVARCHAR(255)

UPDATE HousingData..NashvileHousing
SET PropertySplit_Address = PARSENAME(REPLACE(PropertyAddress, ',','.'),2)

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingData..NashvileHousing
GROUP BY SoldAsVacant;


--CLEANING  Sold as Vacant column 

UPDATE HousingData..NashvileHousing
SET SoldAsVacant=
       CASE WHEN SoldAsVacant ='N' THEN 'No'
	       WHEN SoldAsVacant ='Y' THEN 'Yes'
		   ELSE SoldAsVacant
		   END 
FROM HousingData..NashvileHousing


--Removing Duplicates
with row_num_cte AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY ParcelID,propertyaddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueId) rownum
FROM HousingData..NashvileHousing
)
DELETE
FROM row_num_cte
WHERE rownum >1


--Delete Unused Columns
SELECT *
FROM HousingData..NashvileHousing

ALTER TABLE HousingData..NashvileHousing
DROP COLUMN PropertyAddress,OwnerAddress,SaleDate