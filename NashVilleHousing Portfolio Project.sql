--Cleaning data using SQL Queries

select *
from PortfolioProject..NashvilleHousing

--Standardize date format

select SaleDate, CONVERT(Date,SaleDate) as Date
from
PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted Date;

update  PortfolioProject..NashvilleHousing
set SaleDateConverted= CONVERT(Date,SaleDate)


--Populate Property Address Data

select PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is NULL



select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join  PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] !=  b.[UniqueID ]
where a.PropertyAddress  is null


update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join  PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] !=  b.[UniqueID ]
where a.PropertyAddress  is null


--Breaking out address into individual columns


select propertyaddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null


select
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) +1, Len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1)

update PortfolioProject..NashvilleHousing
set PropertySplitCity= SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) +1, Len(PropertyAddress))



select * from PortfolioProject..NashvilleHousing



select OwnerAddress
from PortfolioProject..NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject..NashvilleHousing



alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

update PortfolioProject..NashvilleHousing
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


select * from PortfolioProject..NashvilleHousing



--change Y to Yes and N to No

select 
distinct(SoldAsVacant),
COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 1


select SoldAsVacant,
	CASE when SoldAsVacant='Y' then 'Yes'
		 when SoldAsVacant='N' then 'No'
		ELSE SoldAsVacant
		END
from PortfolioProject..NashvilleHousing


update PortfolioProject..NashvilleHousing
set SoldAsVacant=CASE when SoldAsVacant='Y' then 'Yes'
						when SoldAsVacant='N' then 'No'
						ELSE SoldAsVacant
						END



--Remove Duplicates

select * 
from 
PortfolioProject..NashvilleHousing


with RowNumCTE as (
select *,
	ROW_NUMBER() Over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					uniqueid
					) row_num

from PortfolioProject..NashvilleHousing
)
select * 
from RowNumCTE
where row_num>1
order by PropertyAddress



--delete unused columns

select 


alter table Portfolio..NashvilleHousing
drop column OwnerAddress