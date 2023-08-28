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
--3 Breaking out Address Column (too much information in one column currently)


Select PropertyAddress
From SQLPractice.dbo.NashvilleHousing


