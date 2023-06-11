/*
Cleaning Data in SQL Queries
*/

select * 
from PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;





-----------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is NULL


select nh.ParcelID, nh.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, ISNULL(nh.PropertyAddress, nh2.PropertyAddress)
from PortfolioProject..NashvilleHousing nh
join PortfolioProject..NashvilleHousing nh2
	on nh.ParcelID = nh2.ParcelID
	and nh.[UniqueID ] <> nh2.[UniqueID ]
where nh.PropertyAddress is NULL
order by nh.ParcelID

update nh
set PropertyAddress =  ISNULL(nh.PropertyAddress, nh2.PropertyAddress)
from PortfolioProject..NashvilleHousing nh
join PortfolioProject..NashvilleHousing nh2
	on nh.ParcelID = nh2.ParcelID
	and nh.[UniqueID ] <> nh2.[UniqueID ]
where nh.PropertyAddress is NULL



-----------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (address, city, state)

select [UniqueID ], PropertyAddress, (LEN(PropertyAddress) - LEN(REPLACE(PropertyAddress, ',', ''))) as NumberOfCommas
from PortfolioProject..NashvilleHousing
order by NumberOfCommas desc

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


select ParcelID, OwnerName, 
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)),
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)),
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1))
from PortfolioProject..NashvilleHousing
order by ParcelID

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnerSplitState nvarchar(30)

Update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)),
    OwnerSplitCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)),
	OwnerSplitState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1))

select * 
from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No respectively

select (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
	CASE
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
	END
from PortfolioProject..NashvilleHousing
where SoldAsVacant in ('Y', 'N')

update PortfolioProject..NashvilleHousing
set SoldAsVacant = 
	CASE
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
	END
where SoldAsVacant in ('Y', 'N')

select (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2






-----------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

with RowNumCTE as
(
select *,
	ROW_NUMBER() OVER(
		Partition by 
			ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference
			order by UniqueID
	) as row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select *
--delete 
from RowNumCTE
where row_num > 1
order by PropertyAddress





-----------------------------------------------------------------------------------------------------------------------

-- Delete unused columns

select * 
from PortfolioProject..NashvilleHousing










