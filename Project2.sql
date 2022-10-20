
--To see all the data
Select * From [Project2.0]..HousingData;


--To Remove Time stamp from the data
--There are two methods for doing this.

--1st Method:

Update [Project2.0]..HousingData
SET SaleDate = CONVERT(Date,SaleDate);

--This First method is not working in my case.

--2nd Method

ALTER TABLE [Project2.0]..HousingData
ADD SaleDateConverted Date;

Update [Project2.0]..HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate);



--To See the information regarding PropertyAdress

SELECT ParcelID, PropertyAddress
From [Project2.0]..HousingData
Where PropertyAddress is NULL;


--Let's populate these NULL addresses

Select a.ParcelID,a.PropertyAddress,b.parcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Project2.0]..Housingdata as a
JOIN [Project2.0]..Housingdata as b
ON a.[ParcelID]=b.[ParcelID]
AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL;


--Now let's update data in NULL cells of ProperpertyAddress

UPDATE a
SET a.propertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Project2.0]..Housingdata as a
JOIN [Project2.0]..Housingdata as b
ON a.[ParcelID]=b.[ParcelID]
AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL;



--Break Address in Individual Columns (Address, City, State)

Select PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),                    ---- For Address
SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))       --------For City
from [Project2.0]..HousingData


ALTER TABLE [Project2.0]..HousingData
ADD Address_Seprated nvarchar(255);

ALTER TABLE [Project2.0]..HousingData
ADD City_Seprated nvarchar(255);

Update [Project2.0]..HousingData
SET Address_Seprated = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);                   ---- For Address

Update [Project2.0]..HousingData
SET City_Seprated = SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));    ---- For City


SELECT OwnerAddress
From [Project2.0]..HousingData
Where OwnerAddress is not NULL

--LET"S EXTRACT STATE FROM HERE AND CREATE SEPRATE COLUMN FOR STATE

Update [Project2.0]..HousingData
SET OwnerAddress= REPLACE(OwnerAddress, '-', ',')

SELECT
PARSENAME(Replace(OwnerAddress,',','.') ,1)
From [Project2.0].dbo.HousingData


Alter Table [Project2.0].dbo.HousingData
ADD State nvarchar(255);


UPDATE [Project2.0].dbo.HousingData
SET State = PARSENAME(Replace(OwnerAddress,',','.') ,1)
From [Project2.0].dbo.HousingData;


--LET"S EXTRACT STATE,CITY AND ADDRESS FROM OWNERADDRESSAND CREATE SEPRATE COLUMN FOR EACH

Update [Project2.0]..HousingData
SET OwnerAddress= REPLACE(OwnerAddress, '-', ',')

SELECT
PARSENAME(Replace(OwnerAddress,',','.') ,1)
From [Project2.0].dbo.HousingData


Alter Table [Project2.0].dbo.HousingData
ADD State nvarchar(255);


UPDATE [Project2.0].dbo.HousingData
SET State = PARSENAME(Replace(OwnerAddress,',','.') ,1)
From [Project2.0].dbo.HousingData;



ALTER TABLE [Project2.0].dbo.HousingData
ADD Owner_Address_Seprated nvarchar(255);

ALTER TABLE [Project2.0].dbo.HousingData
ADD Owner_City_Seprated nvarchar(255);

Update [Project2.0].dbo.HousingData
SET Owner_Address_Seprated = PARSENAME(Replace(OwnerAddress,',','.') ,3)                   ---- For Address

Update [Project2.0].dbo.HousingData
SET Owner_City_Seprated= PARSENAME(Replace(OwnerAddress,',','.') ,2)    ---- For City




--CHANGE THE Y and N to YES and NO in the SoldasVacant Field

Select distinct SoldAsVacant, COUNT(SoldasVacant)              --- This statement is to check the number of distincts values in SoldasVacant Field
From [Project2.0]..HousingData
Group By SoldAsVacant
order by 2

--Now Let's change N and Y to No and Yes

Select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From [Project2.0]..HousingData

Update [Project2.0]..HousingData
SET SoldAsVacant = Case
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From [Project2.0]..HousingData




--DROP THE UNUSED COLUMNS

ALTER TABLE [Project2.0]..HousingData
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict

SELECT *
FROM [Project2.0]..HousingData

--Remove Duplicates

				--For this purpose we have to create a CTE

WITH RCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	Partition by ParcelID,
	SaleDate,
	SalePrice,
	LegalReference
	Order by
		UniqueID
		) row_num
From [Project2.0]..HousingData
)
SELECT * FROM RCTE
Where row_num >1
