select * from NashvilleHousing


-- Standardize Date format 

select saledate, to_date(saledate, 'Month.DD.YYYY') 
from NashvilleHousing

update NashvilleHousing
set saledate = to_date(saledate, 'Month.DD.YYYY')

alter table nashvillehousing
add SaleDateConverted date;

update nashvillehousing
set SaleDateConverted = to_date(saledate, 'YYYY.MM.DD')


-- Populate property adress data

select propertyaddress 
from NashvilleHousing
where propertyaddress is null 

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, coalesce(b.propertyaddress , a.propertyaddress)
from NashvilleHousing as a
join NashvilleHousing as b  
on a.parcelid = b.parcelid
and a."UniqueID " <> b."UniqueID "
where a.propertyaddress is null;

update nashvillehousing as a 
set propertyaddress = coalesce(b.propertyaddress , a.propertyaddress)
from NashvilleHousing as b  
where a."UniqueID " <> b."UniqueID "
and a.propertyaddress is null

-- Breaking out Adress into Individual Columns(Adress, City, State)

select propertyaddress
from NashvilleHousing


select substring(propertyaddress, 1, strpos(propertyaddress, ',') -1) as adress,
substring(propertyaddress, strpos(propertyaddress, ',') +1) as adress
from NashvilleHousing


alter table nashvillehousing
add PropertySplitAdress varchar(255);

update nashvillehousing
set PropertySplitAdress = substring(propertyaddress, 1, strpos(propertyaddress, ',') -1)


alter table nashvillehousing
add PropertySplitCity varchar(255);

update nashvillehousing
set PropertySplitCity = substring(propertyaddress, strpos(propertyaddress, ',') +1)

select * from NashvilleHousing



select owneraddress from NashvilleHousing

select
split_part(owneraddress, ',', 1),
split_part(owneraddress, ',', 2),
split_part(owneraddress, ',', 3)
from nashvillehousing

alter table nashvillehousing
add OwnerSplitAdress varchar(255);

update nashvillehousing
set OwnerSplitAdress = split_part(owneraddress, ',', 1)

alter table nashvillehousing
add OwnerSplitCity varchar(255);

update nashvillehousing
set OwnerSplitCity = split_part(owneraddress, ',', 2)

alter table nashvillehousing
add OwnerSplitState varchar(255);

update nashvillehousing
set OwnerSplitState = split_part(owneraddress, ',', 3)

select * from NashvilleHousing


-- Change Y and N to Yes and No in "soldasvacant"

select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2

select soldasvacant,
	case when soldasvacant = 'N' then 'No'
		 when soldasvacant = 'Y' then 'Yes'
		 else soldasvacant
		 end
from nashvillehousing

update nashvillehousing 
set soldasvacant = case when soldasvacant = 'N' then 'No'
		 when soldasvacant = 'Y' then 'Yes'
		 else soldasvacant
		 end
		 

-- Remove duplicates
	
		 
/*select * from NashvilleHousing

with rownumCTE as (
select *,
row_number() over (partition by
	parcelid, propertyaddress, saledate, saleprice, legalreference
	order by "UniqueID "
	) as row_num
	from nashvillehousing
)
delete
from rownumCTE
where row_num > 1

*/ -- This Query for MySQL
--------------------------------------

create temp table r_n as(
select *,
row_number() over (partition by
	parcelid, propertyaddress, saledate, saleprice, legalreference
	order by "UniqueID "
	) as row_num
	from nashvillehousing
)

delete from  r_n
where row_num > 1

select * from r_n

alter table r_n
drop column row_num,
drop column rn

DELETE FROM nashvillehousing  returning *

insert into nashvillehousing 
select * from r_n

select * from nashvillehousing


-- Delete Unused Columns

select * from nashvillehousing

alter table nashvillehousing
drop column propertyaddress,
drop column taxdistrict,
drop column owneraddress
