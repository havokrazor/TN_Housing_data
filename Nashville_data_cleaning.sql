#Fixing the date format

select SaleDateConverted , convert(SaleDate , date)
FROM sql_project.nashville_housing_data;

ALTER TABLE sql_project.nashville_housing_data
Add SaleDateConverted Date;

UPDATE sql_project.nashville_housing_data
SET SaleDateConverted = convert(SaleDate , date);
---------------------------------------------------------------------------------------------------------
#Populating property address

SELECT PropertyAddress
FROM sql_project.nashville_housing_data
WHERE PropertyAddress is NULL;

SELECT *
FROM sql_project.nashville_housing_data
ORDER BY ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)
From sql_project.nashville_housing_data a
JOIN sql_project.nashville_housing_data b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

Update a
SET PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
FROM sql_project.nashville_housing_data a
JOIN sql_project.nashville_housing_data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;
-------------------------------------------------------------------------------------------------------
#Breaking the Property address into individual columns 

SELECT PropertyAddress
FROM sql_project.nashville_housing_data;

SELECT
substring(PropertyAddress, 1, locate(',', PropertyAddress) -1 ) as Address ,
substring(PropertyAddress, locate(',', PropertyAddress) +1 , length(PropertyAddress)) as Address 
FROM sql_project.nashville_housing_data;

#making new column for the Property address

ALTER TABLE sql_project.nashville_housing_data
Add PropertySplitAddress nvarchar(255);

UPDATE sql_project.nashville_housing_data
SET PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress) -1 );

ALTER TABLE sql_project.nashville_housing_data
Add PropertySplitCity nvarchar(255);

UPDATE sql_project.nashville_housing_data
SET PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) +1 , length(PropertyAddress));

#Checking the new columns in the dataset

SELECT *
FROM sql_project.nashville_housing_data;

#Breaking the Owner Address

SELECT OwnerAddress
FROM sql_project.nashville_housing_data;

SELECT
substring(OwnerAddress, 1, locate(',', OwnerAddress) -1 ) as Address ,
substring(OwnerAddress, locate(',', OwnerAddress) +1, length(OwnerAddress)) as Address,
substring(OwnerAddress, locate('TN', OwnerAddress) -1, length(OwnerAddress)) as Address
FROM sql_project.nashville_housing_data;

#Creating new columns for Address , City and state

ALTER TABLE sql_project.nashville_housing_data
Add OwnerSplitAddress nvarchar(255);

UPDATE sql_project.nashville_housing_data
SET OwnerSplitAddress = substring(OwnerAddress, 1, locate(',', OwnerAddress) -1 );

ALTER TABLE sql_project.nashville_housing_data
Add OwnerCityAddress nvarchar(255);

UPDATE sql_project.nashville_housing_data
SET OwnerCityAddress = substring(OwnerAddress, locate(',', OwnerAddress) +1, length(OwnerAddress));

ALTER TABLE sql_project.nashville_housing_data
Add OwnerStateAddress nvarchar(255);

UPDATE sql_project.nashville_housing_data
SET OwnerStateAddress = substring(OwnerAddress, locate('TN', OwnerAddress) -1, length(OwnerAddress));

update sql_project.nashville_housing_data
SET OwnerCityAddress = replace(OwnerCityAddress, ', TN', '');

-----------------------------------------------------------------------------------------------
#Change Y and N to Yes and No in "SoldAsVacant"

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From sql_project.nashville_housing_data
Group by SoldAsVacant
order by 2;

select SoldAsVacant,
CASE 
    When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END as SAVcorrect 
FROM sql_project.nashville_housing_data;

update sql_project.nashville_housing_data
set SoldAsVacant = CASE 
    When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

------------------------------------------------------------------------------------------------------

#Remove Duplicate 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From sql_project.nashville_housing_data
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From sql_project.nashville_housing_data
)
delete
From RowNumCTE
Where row_num > 1;

--------------------------------------------------------------------------------------------------------

#Deleting unused columns

ALTER TABLE sql_project.nashville_housing_data
drop OwnerAddress,
drop TaxDistrict,
drop PropertyAddress,
drop SaleDate;

Select *
From sql_project.nashville_housing_data;

