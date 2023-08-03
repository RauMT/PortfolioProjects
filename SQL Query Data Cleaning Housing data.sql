/*

Cleaning Data in SQL Queries 

*/

SELECT * 
FROM PortfolioProject1..Housing

------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
		-- First method did not work on this Dataset
		-- Therefore a second method was used 

SELECT SaleDate, CONVERT(Date,SaleDate) AS Date 
FROM PortfolioProject1..Housing

UPDATE Housing
SET SaleDate = CONVERT(Date,SaleDate)

SELECT SaleDate
FROM PortfolioProject1..Housing

		-- Second method, creating a new column And fill that with SaleDate data converted to Date type
ALTER TABLE Housing
ADD SaleDateConverted Date; 

UPDATE Housing
SET SaleDateConverted = Convert(Date, SaleDate)

		-- Check result
SELECT SaleDate, SaleDateConverted
FROM PortfolioProject1..Housing


--------------------------------------------------------------------------------------------------------------

-- Populate  Property Address data 
		-- Check the Property Adress that are Null 
SELECT *
FROM PortfolioProject1..Housing
WHERE PropertyAddress IS NULL 
--ORDER BY parcelID

SELECT *
FROM PortfolioProject1..Housing
WHERE PropertyAddress IS NULL 
ORDER BY parcelID

		-- Create a Join between the dataset itself to identify the Property Address for the cases with NULL and fills the row with that property Adress by using ISNULL
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..Housing a
JOIN PortfolioProject1..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

		-- Update the dataset
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..Housing a
JOIN PortfolioProject1..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

		-- Check results
SELECT PropertyAddress 
FROM PortfolioProject1..Housing
WHERE PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject1..Housing

		-- Search for the Substring from position 1 till the position of the delimiter ',' - 1 for Address
		-- Search for the Substring from position position of the delimiter ',' + 1 till the end of the PropertyAddress using LEN for City
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) AS Address
, SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress) +1), LEN(PropertyAddress)) AS City 
FROM PortfolioProject1..Housing

		-- Create and Update Table
ALTER TABLE PortfolioProject1..Housing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE PortfolioProject1..Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

		-- Create and Update Table  	
ALTER TABLE PortfolioProject1..Housing
ADD PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject1..Housing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress) +1), LEN(PropertyAddress))

		-- Check result
SELECT *
FROM PortfolioProject1..Housing

		
-- Breaking out OwnerAddress into individual Columns (Address, City, State) using different method PARSENAME
		-- Use REPLACE as PARSENAME USES '.' instead of ',' 
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS Adress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS State
FROM PortfolioProject1..Housing
WHERE OwnerAddress IS NOT NULL

		-- Create, Update Table
ALTER TABLE PortfolioProject1..Housing
ADD OwnerSplitAddress (255)

UPDATE PortfolioProject1..Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PortfolioProject1..Housing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject1..Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PortfolioProject1..Housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject1..Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

		--Check result
SELECT *
FROM PortfolioProject1..Housing
WHERE OwnerAddress IS NOT NULL

-----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant

		-- Look at the different values from SoldAsVacant
SELECT SoldAsVacant, COUNT(SoldAsVacant) 
FROM PortfolioProject1..Housing
GROUP BY SoldAsVacant
Order BY 2

		-- Use CASE STATEMENT to change value
SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N'THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject1..Housing

		-- Update Table
UPDATE PortfolioProject1..Housing
SET SoldAsVacant = 
	  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N'THEN 'No'
	  ELSE SoldAsVacant
	  END

		-- Check results
SELECT SoldAsVacant, COUNT(SoldAsVacant) 
FROM PortfolioProject1..Housing
GROUP BY SoldAsVacant
Order BY 2




-------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

		-- Use CTE to create Temp Table to find to duplicate row using WHERE row_num >1
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
			     SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

 
FROM PortfolioProject1..Housing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress

		-- Check results
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
			     SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

 
FROM PortfolioProject1..Housing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num >1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns (Mostly used when creating views, no raw data)

ALTER TABLE PortfolioProject1..Housing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject1..Housing
DROP COLUMN SaleDate

		-- Check Result
SELECT * 
FROM PortfolioProject1..Housing
