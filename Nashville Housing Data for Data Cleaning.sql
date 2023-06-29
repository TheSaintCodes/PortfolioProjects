/*
ETL Cleaning Data In SQL Queries
*/

SELECT * FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format
SELECT 
	SaleDate, CONVERT(date,SaleDate)
FROM 
	PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate) 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate);


--Populate Property Address Data

SELECT
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress       
FROM 
	PortfolioProject.dbo.NashvilleHousing AS a
JOIN 
	PortfolioProject.dbo.NashvilleHousing AS b
ON  a.ParcelID = b.ParcelID
	AND
	a.[UniqueID ] <> b.[UniqueID ]
--WHERE 
--	a.PropertyAddress IS NULL
 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortfolioProject.dbo.NashvilleHousing AS a
JOIN 
	PortfolioProject.dbo.NashvilleHousing AS b
ON	a.ParcelID = b.ParcelID
	AND
	a.[UniqueID ] <> b.[UniqueID ] 


--Breaking out Address into Individual Columns (Address, City, State)
--PropertyAddress using SUBSTRING
SELECT
	PropertyAddress       
FROM 
	PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS AddressStreet,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS AddressCity
FROM 
	PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyStreet Nvarchar(255)

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));


--OwnerAddress Using PARSENAME
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitStreet,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerSplitState
FROM 
	PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitStreet Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3);
 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


---Change Y and N to Yes and No in "SoldAsVacant" Field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM 
	PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM 
	PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END;


--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
				 PropertyAddress, 
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) AS row_num				
FROM PortfolioProject.dbo.NashvilleHousing 
--ORDER BY ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER by PropertyAddress


--Delete Unused Column
SElECT * FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict