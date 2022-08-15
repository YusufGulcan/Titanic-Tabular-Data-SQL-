#See the table 
select
    *
from
    titanic;

# Get the average age and avg spending made by people who go to TRAPPIST-1e
select
    Homeplanet,
    avg(Age),
    avg(RoomService + FoodCourt + ShoppingMall + Spa + VRDeck) as avg_spending
from
    titanic
where
    Destination = 'TRAPPIST-1e';

#the most common destination and homeplanet with counts, avg age and avg spending
select
    avg(RoomService + FoodCourt + ShoppingMall + Spa + VRDeck) as avg_spending,
    avg(age),
    Homeplanet,
    count(HomePlanet),
    Destination,
    count(Destination)
from
    titanic;

# create a new column called total spending and turn the data into a categorized form 
select
    HomePlanet,
    CryoSleep,
    Cabin,
    Destination,
    Age,
    VIP,
    total_spending,
    Case
        when total_spending > 10000 then 'High'
        when total_spending < 10000 then 'Low'
    end as Category
from
    (
        select
            r.PassengerId,
            t.HomePlanet,
            t.CryoSleep,
            t.Cabin,
            t.Destination,
            t.Age,
            t.VIP,
            r.total_spending
        from
            titanic t
            join (
                select
                    PassengerId,
                    (RoomService + FoodCourt + ShoppingMall + Spa + VRDeck) as total_spending
                from
                    titanic
            ) as r on t.PassengerId = r.PassengerId
    ) as e;

#create view  of the table above
create view
    titanic_spending as
select
    HomePlanet,
    CryoSleep,
    Cabin,
    Destination,
    Age,
    VIP,
    Total_spending,
    case
        when total_spending > 10000 then 'High'
        when total_spending < 10000 then 'Low'
    end as Category
from
    (
        select
            r.PassengerId,
            t.HomePlanet,
            t.CryoSleep,
            t.Cabin,
            t.Destination,
            t.Age,
            t.VIP,
            r.total_spending
        from
            titanic t
            join (
                select
                    PassengerId,
                    (RoomService + FoodCourt + ShoppingMall + Spa + VRDeck) as total_spending
                from
                    titanic
            ) as r on t.PassengerId = r.PassengerId
    ) as e;

#check out the the new view 
select
    *
from
    titanic_spending;

# Aggregate numbers for the each variables in the new category
select
    HomePlanet,
    count(HomePlanet),
    CryoSleep,
    count(CryoSleep),
    avg(Age),
    Avg(Total_spending)
from
    titanic_spending
group by
    Category
order by
    Category;

# Data grouped by category and HomePlanet
select
    HomePlanet,
    count(HomePlanet),
    count(Destination),
    Destination,
    avg(Age),
    Count(VIP),
    VIP,
    avg(Total_spending),
    category
from
    titanic_spending
group by
    category,
    VIP
order by
    avg(Total_spending) desc;

# the Highest average Spenders grouped by HomePlanet
select
    HomePlanet,
    count(HomePlanet),
    avg(Total_spending),
    avg(Age)
from
    titanic_spending
group by
    HomePlanet
order by
    avg(Total_spending) desc;

# The difference between the highest spending and  the lowest spending
select
    (max(Total_spending) - min(Total_spending)) as difference
from
    titanic_spending;

# The Difference in the average spending between the VIP and non-VIP passengers
select
    (
        (
            select
                avg(Total_spending) as avg_sp
            from
                titanic_spending
            where
                VIP = 'True'
        ) - (
            select
                avg(Total_spending) as avg_sp
            from
                titanic_spending
            where
                VIP = 'False'
        )
    ) as VIP_spending;

# The avg Age of people heading to different destinations
select
    avg(age),
    Destination
from
    titanic
group by
    destination;

# Categorization of people in the different stage of life.
select
    Name,
    VIP,
    HomePlanet,
    Destination,
    Age,
    Transported,
    Case
        when Age > 60 then 'Old'
        when Age > 40 then 'Middle Age'
        when Age > 25 then 'Young Adult'
        when Age > 15 then 'Young'
        when Age > 5 then 'Child'
        else 'Toddler'
    end as Stage_of_Life
from
    titanic
order by
    Stage_of_Life;

## Create view of the table above
create view
    age_titanic as
select
    Name,
    VIP,
    HomePlanet,
    Destination,
    Age,
    Transported,
    Case
        when Age > 60 then 'Old'
        when Age > 40 then 'Middle Age'
        when Age > 25 then 'Young Adult'
        when Age > 15 then 'Young'
        when Age > 5 then 'Child'
        else 'Toddler'
    end as Stage_of_Life
from
    titanic
order by
    Stage_of_Life;

select
    *
from
    age_titanic;

# Transportation Rate of Toddlers 
select
    (
        select
            count(name)
        from
            age_titanic
        where
            Stage_of_Life = 'Toddler'
            and Transported = 'True'
    ) / (
        select
            count(name)
        from
            age_titanic
        where
            Stage_of_Life = 'Toddler'
    );

# Transportation Rate of Old people 
select
    (
        select
            count(name)
        from
            age_titanic
        where
            Stage_of_Life = 'Young'
            and Transported = 'True'
    ) / (
        select
            count(name)
        from
            age_titanic
        where
            Stage_of_Life = 'Young'
    );

## Transportation rate of all population
select
    (
        select
            count(PassengerId)
        from
            titanic
        where
            Transported = 'True'
    ) / (
        select
            count(PassengerId)
        from
            titanic
    );

## The avg age of people for different combinations of  homeplanet and destination (Null values filtered)
select
    HomePlanet,
    Destination,
    avg(age)
from
    titanic
where
    HomePlanet <> ''
    and Destination <> ''
group by
    Homeplanet,
    Destination
order by
    Homeplanet;

## the percentage of total spending made by young adults.
select
    (
        (
            select
                sum(Total_spending)
            from
                titanic_spending
            where
                age between 25 and 40
        ) / (
            select
                sum(Total_spending)
            from
                titanic_spending
        )
    ) * 100 as spending_young_adults;

## Average age of transported people and ratio of transported people to the all popution
select
    (
        select
            avg(age)
        from
            titanic
        where
            Transported = 'True'
    ) as transported_avg_age,
    (
        select
            count(name)
        from
            titanic
        where
            Transported = 'True'
    ) / (
        select
            count(name)
        from
            titanic
    ) as ratio_of_transported;

## The number of VIP passengers grouped by HomePlanet
select
    HomePlanet,
    count(HomePlanet) as N_Homeplanet
from
    titanic
where
    VIP = 'True'
    and HomePlanet <> ''
group by
    HomePlanet;

## What percentage of VIP passengers take which destination
select
    distinct(Destination),
    (
        count(Destination) over(partition by Destination) / count(HomePlanet) over(partition by VIP)
    ) * 100 as percenta
from
    titanic
where
    VIP = 'True'
    and Destination <> '';

## the number of passengers per destination
select
    Destination,
    count(Destination) as t
from
    titanic
where
    VIP = 'True'
    and Destination <> ''
group by
    Destination;

## Percentage of passengers that take different destinations
select
    distinct(destination),
    (
        count(destination) over(partition by destination) / count(*) over()
    ) * 100 as percentage
from
    titanic
where
    destination <> '';

## Create a new column called deck 
Alter table
    titanic
add
    column Deck char(25);

## split the cabin deck no from the cabin column as a new column and add 
## those values to the newly created column.
insert into
    titanic(Deck)
select
    Dde
from
    (
        select
            *,
            case
                when SUBSTRING(Cabin, 1, 1) = 'A' then 'A'
                when SUBSTRING(Cabin, 1, 1) = 'B' then 'B'
                when SUBSTRING(Cabin, 1, 1) = 'C' then 'C'
                when SUBSTRING(Cabin, 1, 1) = 'D' then 'D'
                when SUBSTRING(Cabin, 1, 1) = 'E' then 'E'
                when SUBSTRING(Cabin, 1, 1) = 'F' then 'F'
                when SUBSTRING(Cabin, 1, 1) = 'G' then 'G'
                else 'Other'
            end as Dde
        from
            titanic
    ) as e;

## The percentage of expenditure made by people who are categorized according to Transportation situation
select
    distinct(Transported),
    (
        sum(ShoppingMall + Spa + VRDeck + RoomService + FoodCourt) over(partition by Transported) / sum(ShoppingMall + Spa + VRDeck + RoomService + FoodCourt) over()
    ) * 100 as Expenditure
from
    titanic
where
    Transported <> '';

## Average age for people leading different destinations.
select
    distinct(destination),
    avg(age) over (partition by Destination) as Avg_Age
from
    titanic
where
    Destination <> '';

## Average age for people leading different home planet.
select
    distinct(HomePlanet),
    avg(age) over (partition by HomePlanet) as Avg_Age
from
    titanic
where
    HomePlanet <> '';

## Create view that includes column of passenger cabin type
create view
    rooms as (
        select
            *,
            case
                when SUBSTRING(Cabin, 1, 1) = 'A' then 'A'
                when SUBSTRING(Cabin, 1, 1) = 'B' then 'B'
                when SUBSTRING(Cabin, 1, 1) = 'C' then 'C'
                when SUBSTRING(Cabin, 1, 1) = 'D' then 'D'
                when SUBSTRING(Cabin, 1, 1) = 'E' then 'E'
                when SUBSTRING(Cabin, 1, 1) = 'F' then 'F'
                when SUBSTRING(Cabin, 1, 1) = 'G' then 'G'
                else 'Other'
            end as Deck_Type,
            case
                when SUBSTRING(Cabin, 5, 1) = 'P' then 'P'
                when SUBSTRING(Cabin, 5, 1) = 'S' then 'S'
                else 'Other'
            end as Cabin_Type
        from
            titanic
    );

select
    *
from
    rooms;
