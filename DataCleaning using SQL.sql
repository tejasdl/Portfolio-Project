
/*

Data Cleaning


*/


Select * 
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------
--Convert SaleDate from Date time to just Date

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add SaleDateTo Date;

Update NashvilleHousing
SET SaleDateTo = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------

--Investigating PropertyAddress

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

--Populate ProperAddress data

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

--Something like Property address wont change it is fixed, we can almost certainly populate the ProprtyAddress using certain reference point.

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--During data Exploration we found that ParcelID gives same info as PropertyAddress, So we can populate  the null values in PropertyAddress with Address value corresponding to that ParcelID in other rows 

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--Self Joint

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------

--Breaking Out Address into Individual column(Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

--In the Property Address column there is address and city name seperated by comma delimiter


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress,',', '.'), 3)
,PARSENAME(Replace(OwnerAddress,',', '.'), 2)
,PARSENAME(Replace(OwnerAddress,',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'), 1)



---------------------------------------------------------------------------------------------------------------------------------

--Changing the values in SoldAsVacant field as Yes and No

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
   When SoldAsVacant = 'N' THEN 'No'
   Else SoldAsVacant
   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
   When SoldAsVacant = 'N' THEN 'No'
   Else SoldAsVacant
   END

-------------------------------------------------------------------------------------------------------------------------------

--Removing Duplicates

WITH RowNumCTE as (
Select*,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num


From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1


-------------------------------------------------------------------------------------------------------------------------------
--Delete un-necessary Columns

Select * 
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


