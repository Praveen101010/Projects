SELECT * FROM Housing_Data_cleaning..Nashville_housing

--DATA CLEANING Nashville housing

--Standardize date format

SELECT saleDate 
FROM Housing_Data_cleaning..Nashville_housing

ALTER TABLE Nashville_housing
ADD SaleDateConverted DATE;

Update Nashville_housing
SET SaleDateConverted = CONVERT(Date,saleDate)


SELECT saleDate, SaleDateConverted
FROM Housing_Data_cleaning..Nashville_housing

--Property Address data

Select  PropertyAddress
FROM Nashville_housing
WHERE PropertyAddress is NULL

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_housing a
JOIN Nashville_housing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NOT NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_housing a
JOIN Nashville_housing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL


-- Breaking out Address into Individual columns(Address, city, state)

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Nashville_Housing

ALTER TABLE Nashville_housing
ADD PropertySplitAddress Nvarchar(250);

Update Nashville_housing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE Nashville_housing
ADD City Nvarchar(250);

Update Nashville_housing
SET City = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT * FROM Nashville_housing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM Nashville_housing

ALTER TABLE Nashville_housing
ADD OwnersplitAddress Nvarchar(250);

Update Nashville_housing
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE Nashville_housing
ADD OwnerCity Nvarchar(250);

Update Nashville_housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_housing
ADD Ownerstate Nvarchar(250);

Update Nashville_housing
SET Ownerstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM Nashville_housing

--Change Y and N to Yes and no in "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant) , Count(SoldAsVacant)
FROM Nashville_housing
Group by SoldAsVacant
Order by  2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant
	 END
FROM Nashville_housing

UPDATE Nashville_housing
SET  SoldAsVacant = CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant
	 END

--Remove Duplicates


WITH ROWNUMCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) row_num
FROM Nashville_housing
--ORDER BY ParcelID
)

DELETE
FROM ROWNUMCTE
WHERE row_num >1

WITH ROWNUMCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) row_num
FROM Nashville_housing
--ORDER BY ParcelID
)
SELECT *
FROM ROWNUMCTE
WHERE row_num >1

--DELETE unused columns
--I will delete state column as well because i created it by mistake when splitting addresses in above queries

SELECT * FROM Nashville_housing

ALTER TABLE Nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, state, SaleDate, PropertyAddress