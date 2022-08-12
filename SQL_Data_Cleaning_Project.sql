-- Data Cleaning Project

-- Standardise Date Format

ALTER TABLE Nashvillehousing
ADD SaleDate2 Date;

UPDATE Nashvillehousing
SET SaleDate2 = CONVERT(Date, SaleDate)

SELECT *
FROM Portfolio_Project_2.dbo.Nashvillehousing

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project_2.dbo.Nashvillehousing as a
JOIN Portfolio_Project_2.dbo.Nashvillehousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project_2.dbo.Nashvillehousing as a
JOIN Portfolio_Project_2.dbo.Nashvillehousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address Column into Individual Columns (Address, City, State)

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress)) as City
FROM Portfolio_Project_2.dbo.Nashvillehousing


ALTER TABLE Nashvillehousing
ADD Address Nvarchar(255)

UPDATE Nashvillehousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) 

ALTER TABLE Nashvillehousing
ADD City Nvarchar(255)

UPDATE Nashvillehousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress))

-- Through PARSENAME()

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM Portfolio_Project_2.dbo.Nashvillehousing


ALTER TABLE Nashvillehousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE Nashvillehousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE Nashvillehousing
ADD OwnerSplitState Nvarchar(255)

UPDATE Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project_2.dbo.Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM Portfolio_Project_2.dbo.Nashvillehousing

UPDATE Nashvillehousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END 

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH Row_Num_CTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY ParcelID) row_num
FROM Portfolio_Project_2.dbo.Nashvillehousing
)

SELECT * 
FROM Row_Num_CTE
WHERE row_num > 1

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM Portfolio_Project_2.dbo.Nashvillehousing

ALTER TABLE Portfolio_Project_2.dbo.Nashvillehousing
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE Portfolio_Project_2.dbo.Nashvillehousing
DROP COLUMN SaleDate