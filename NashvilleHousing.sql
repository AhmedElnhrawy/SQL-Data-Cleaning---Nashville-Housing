/*


Cleaning Data Using SQL Queries


The Cleaning Process will be done trough three general steps :

	> Resolving Errors, Nulls and reformating columns.
	> Spotlight on Errors, Nulls and formats that requires reference to be resolved and/or confirmed.
	> Adding more Columns for Analysis and Visualizations purposes. 

*/

-----------------------------------------------------------------------------------------

-- 1- Resolving Errors, Nulls and reformating columns.


-- Standarizing Date Formate for (SalesDate) Column

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

SELECT SaleDate
FROM NashvilleHousing

-----------------------------------------------------------------------------------------

-- Populating Nulls in "PropertAddress" Column

	
SELECT a.ParcelID , b.ParcelID ,a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------

-- Dividing Address Column into 3 Individual Columns (Address, City, State)


-- PropertyAddress Column is Divided to (PropertyAddress, PropertyCity)

SELECT
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertyAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


-- OwnerAddress Column is Divided to (OwnerAddress, OwnertCity ,OwnerState)

SELECT
		PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
		PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
		PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnertCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-----------------------------------------------------------------------------------------

-- Changing Y and N to Yes and Now in "SoldAsVacant" Column

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing

SELECT SoldAsVacant,
	   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant END
FROM NashvilleHousing

-- Updating corrections values for "SoldAsVacant" column

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant END


-----------------------------------------------------------------------------------------

-- Removing duplicates with considering all these columns (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) Columns.

WITH Duplicates AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID,
										  PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference
										  ORDER BY UniqueID) AS Dup

					FROM NashvilleHousing) 
DELETE
FROM Duplicates
WHERE Dup > 1


-----------------------------------------------------------------------------------------

-- Drop unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE NashvilleHousing
DROP COLUMN  TaxDistrict

-----------------------------------------------------------------------------------------

--  2-Spotlight on Errors, Nulls and formats that requires reference to be resolved


-- Finding Nulls and wrong values in all columns.

SELECT DISTINCT Acreage
FROM NashvilleHousing
ORDER BY 1

-- There are Nulls and multiple values that requires reference to be resolved and/or confirmed.

SELECT DISTINCT SalePrice
FROM NashvilleHousing
ORDER BY 1 

-- There are very low values that requires reference to be resolved and/or confirmed.

SELECT DISTINCT LegalReference
FROM NashvilleHousing
ORDER BY 1

-- There are Negative Values that requires reference to be resolved and/or confirmed.

SELECT DISTINCT LandValue
FROM NashvilleHousing
ORDER BY 1

-- There are nulls and quite low values that requires reference to be resolved and/or confirmed.


SELECT DISTINCT BuildingValue
FROM NashvilleHousing
ORDER BY 1

-- There are nulls and 0 values that requires reference to be resolved and/or confirmed.


SELECT DISTINCT TotalValue
FROM NashvilleHousing
ORDER BY 1

-- There are nulls and quite low values that requires reference to be resolved and/or confirmed.

SELECT DISTINCT YearBuilt
FROM NashvilleHousing
ORDER BY 1

-- There are nulls  requires reference to be resolved or dropped.

SELECT DISTINCT Bedrooms
FROM NashvilleHousing
ORDER BY 1

-- There are nulls and 0 values that requires reference to be resolved and/or confirmed.

SELECT DISTINCT FullBath
FROM NashvilleHousing
ORDER BY 1

-- There are nulls and 0 values that requires reference to be resolved and/or confirmed.

SELECT DISTINCT HalfBath
FROM NashvilleHousing
ORDER BY 1

-- There are nulls and 0 values that requires reference to be resolved and/or confirmed.

-----------------------------------------------------------------------------------------

-- TotalValue column has to  be the summation of LandValue Column and BuildingValue Column.

SELECT LandValue, BuildingValue, TotalValue
FROM NashvilleHousing
WHERE LandValue + BuildingValue  <> TotalValue

-- There are many Values require reference to be resolved.

-----------------------------------------------------------------------------------------

-- Adding more Columns for Analysis and Visualizations purposes. 


-- Adding Profit/Loss Column for Analysis purposes.


SELECT [UniqueID ], SalePrice, TotalValue,	SalePrice - TotalValue  AS [Profit/Loss]	
FROM NashvilleHousing


-- Adding DepartmentSize  Column for Visualizations purposes.

ALTER TABLE NashvilleHousing
  ADD ApartmentSize AS
    CASE
      WHEN (Bedrooms > 5) THEN 'Large'
      WHEN (Bedrooms > 3) THEN 'Medium'
      ELSE 'Small'
    END

-----------------------------------------------------------------------------------------
/*

Here we go, Now we have Clean, Tidy data and ready for the next step.

*\