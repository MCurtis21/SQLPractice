--Cleaning Data Practice

Select * 
From SQLPractice.dbo.NashvilleHousing

---------------------------------------------------------------------
--1 Standardize Date Format

Select SaleDateNew, CONVERT(Date,SaleDate)
From SQLPractice.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Select SaleDate
--From SQLPractice.dbo.NashvilleHousing
--Didn't update properly

ALTER TABLE NashvilleHousing
Add SaleDateNew Date;

Update NashvilleHousing
SET SaleDateNew = CONVERT(Date,SaleDate)

---------------------------------------------------------------------
--2 Populate Property Address Data

Select * 
From SQLPractice.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLPractice.dbo.NashvilleHousing a
Join SQLPractice.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLPractice.dbo.NashvilleHousing a
Join SQLPractice.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null


---------------------------------------------------------------------
--3a Breaking out PropertyAddress Column using substring (too much information in one column currently)


Select PropertyAddress
From SQLPractice.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From SQLPractice.dbo.NashvilleHousing

ALTER TABLE SQLPractice.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update SQLPractice.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE SQLPractice.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update SQLPractice.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From SQLPractice.dbo.NashvilleHousing

---------------------------------------------------------------------
--3b Breaking out OwnerAddress Column using parsename (too much information in one column currently)

Select OwnerAddress

From SQLPractice.dbo.NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'),3)
, PARSENAME(Replace(OwnerAddress, ',', '.'),2)
, PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From SQLPractice.dbo.NashvilleHousing

ALTER TABLE SQLPractice.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update SQLPractice.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)

ALTER TABLE SQLPractice.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update SQLPractice.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)

ALTER TABLE SQLPractice.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update SQLPractice.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)

Select *
From SQLPractice.dbo.NashvilleHousing

---------------------------------------------------------------------
--4 SoldAsVacant column has inconsistent values (some yes, some no, some y, some n)
--Let's change the y and n to yes and no


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From SQLPractice.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From SQLPractice.dbo.NashvilleHousing

Update SQLPractice.dbo.NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From SQLPractice.dbo.NashvilleHousing

---------------------------------------------------------------------
--5a Removing Duplicates (must be careful when removing data)

Select *
From SQLPractice.dbo.NashvilleHousing

WITH RowNumCTE AS(
Select *,
	Row_Number() Over(
	Partition BY ParcelID,
							PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference
							ORDER BY
								UniqueID
								) row_num


From SQLPractice.dbo.NashvilleHousing
)
DELETE 
--Select *
FROM RowNumCTE
WHERE row_num > 1
--Order BY PropertyAddress
--ORDER BY ParcelID

---------------------------------------------------------------------
--5b Removing unused columns (must be careful when removing data)

Select *
From SQLPractice.dbo.NashvilleHousing

ALTER TABLE SQLPractice.dbo.NashvilleHousing
Drop Column SaleDate, PropertyAddress

ALTER TABLE SQLPractice.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict