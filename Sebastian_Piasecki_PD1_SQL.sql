/*1. Podstawy DQL:
a. Wypisz zamówienia pracowników 2,4,5. Znajdź imiona i nazwiska tych pracowników*/

select 
	first_name
	, last_name
	, employee_id 
from employees e 
where employee_id in (2,4,5)

/*b. Wypisz zamówienia pracowników o ID parzystym*/

select
	* 
from orders o 
where employee_id % 2 = 0

/*c. Wypisz imiona Pracowników – tak aby poszczególne imię wyświetlono jeden raz. Wyświetl je wielkimi literami.*/

select distinct 
	upper(first_name) 
from employees e 

/*d. Wypisz zamówienia z 2016 roku.*/

select 
	* 
from orders o 
where date_part('YEAR', order_date) = 2016

/*e. Wyznacz z tabeli z pracownikami Pracownika o ID=1, dodaj do wyników zmienną losową. 
 *Jeżeli zmienna losowa ma wartość >0.7 dodaj komunikat „ dodatkowy dzień wolny”, jeżeli będzie pomiędzy 0.1 a 0.7 dodaj komunikat „brak nagrody”, 
 *jeżeli będzie mniejsza od 0.1 podaj komunikat „musisz zrobić nadgodziny”. Wykonaj skrypt kilka razy. Czy komunikat się zmienia?*/

select 
	
	case 	when random() > 0.7 then 'dodatkowy dzien wolny'
			when random() between 0.1 and  0.7 then 'brak nagrody'
			when random() < 0.1 then 'musisz zrobic nadgodziny'
		 	end ZALECENIA_HR
	, *
from employees e where employee_id = 1

/*f. Wyznacz terytorium działania każdego pracownika.*/

select 
	e.first_name
	, e.last_name
	, et.territory_id 
	, t.territory_description  
from employee_territories et 
join territories t on et.territory_id = t.territory_id 
join employees e on et.employee_id = e.employee_id 

/*g. Wyznacz zamówienia z 1 kwartału 2016 roku wraz z dodaniem przewoźnika i jego numeru telefonu.
Z numeru telefonu usuń nawiasy. W wynikach dla zmiennej shipregion, wartości puste zastąp nazwą miasta.*/

select 
	s.company_name
	, replace(replace(s.phone, '(', ''), ')', '') as phone 
	, coalesce(o.ship_region,o.ship_city) as ship_region 
	, * 
from orders o 
join shippers s on o.ship_via = s.shipper_id 
where date_part('YEAR', order_date) = 1997 and date_part('quarter', order_date) = 1

select * from shippers s 

/*h. Wyznacz produkty wraz z nazwą kategorii oraz nazwą dostawcy, dla których w magazynie jest mniej niż 15 jednostek lub są przecenione.*/

select p.product_name, p.product_id, c.category_name, s.company_name from products p 
join suppliers s on p.supplier_id = s.supplier_id 
join categories c on p.category_id = c.category_id 
where p.units_in_stock < 15 or p.discontinued > 0

/*. DQL – JOIN, UNION, FUNKCJE AGREGUJĄCE:
a. Sprawdź ilu jest w bazie pracowników ze stanowiskiem (TITLE) zawierających słowo: „Manager”.*/

select count(*) from employees e where title like '%Manager%'

/*b. Policz ilu jest pracowników, którzy pracują w firmie poszczególną liczbę lat.*/

select count(*), date_part('YEAR', current_date) - date_part('YEAR', hire_date) ilosc_lat from employees e group by date_part('YEAR', current_date) - date_part('YEAR', hire_date) 

/*c. Wyznacz wiek Pracowników w dniu zatrudnienia. Jaka jest maksymalna wartość?*/

select first_name, last_name, date_part('YEAR', hire_date) - date_part('YEAR', birth_date) wiek_w_momencie_zatrudnienia from employees e order by 3 desc

/*d. Do zestawienia liczby pracowników w departamentach dodaj (zakładamy, że DZIŚ MAMY 1 LISTOPADA 2013 ROKU):
i. Liczbę pracowników po 50 r.ż.*/

select 
	sum(case when date_part('YEAR', date'2013-11-01') - date_part('YEAR', birth_date) >= 50 then 1
	else 0 end) wiek
from employees e

/*ii. Liczbę pracowników w wieku emerytalnym (uwzględnij płeć)*/

select 
	sum(case when date_part('YEAR', date'2013-11-01') - date_part('YEAR', birth_date) >= 63 and title_of_courtesy in('Ms.', 'Mrs.') then 1
	else 0 end) wiek_emerytalny_kobiet
	,sum(case when date_part('YEAR', date'2013-11-01') - date_part('YEAR', birth_date) >= 65 and title_of_courtesy in('Mr.', 'Dr.') then 1
	else 0 end) wiek_emerytalny_mezczyzn
from employees e

/*iii. Liczbę pracowników pracujących ponad 3 lata*/

select 
	sum(case when date_part('YEAR', hire_date) - date_part('YEAR', birth_date) >= 3 then 1
	else 0 end) Ilosc_pracownikow_powyzej_3_lat
from employees e

/*iv. Średni, maksymalny, minimalny, staż pracy*/

select 
	round(avg(date_part('YEAR', hire_date) - date_part('YEAR', birth_date))) sredni_staz_pracy  
	,max(date_part('YEAR', hire_date) - date_part('YEAR', birth_date)) najwiekszy_staz_pracy
	,min(date_part('YEAR', hire_date) - date_part('YEAR', birth_date)) najmniejszy_staz_pracy
from employees e

/*e. Sprawdź datę pierwszego i ostatniego zamówienia.*/

select min(order_date) from orders o 

select max(order_date) from orders

/*f. Stwórz zestawienie sprzedaży dla Klientów najświeższy rok. Wyniki podziel na kwartały. wyświetl liczbę zamówień, średnią, maksymalną, minimalną wartość 
  oraz sumę z pól Freight, oraz z kwoty zamówienia.*/

select max(extract(year from order_date)) from orders o

select 
	extract(quarter from  o.order_date)
	,avg(o.freight) srednia_freight
	,min(o.freight) minimalna_freight
	,max(o.freight) maksymalna_freight
	,sum(o.freight) suma_freight 
	,sum(case when o.order_id is not null then 1
	else 0 end) suma_zamowien
	,avg(od.unit_price) srednia_price
	,min(od.unit_price) minimalna_price
	,max(od.unit_price) maksymalna_price
	,sum(od.unit_price) suma_price
from orders o 
join order_details od on o.order_id = od.order_id 
where extract(year from order_date) = 1998
group by extract(quarter from  o.order_date)
 	 

/*g. Stwórz zestawienie sprzedaży dla sklepów za najstarszy rok. Wyniki podziel na z kwartały. wyświetl liczbę zamówień, średnią, maksymalną,
  minimalną wartość oraz sumę z pól Freight, SUBTOTAL, oraz TOTALDUE.*/

select min(extract(year from order_date)) from orders o

select 
	extract(quarter from  o.order_date)
	,avg(o.freight) srednia_freight
	,min(o.freight) minimalna_freight
	,max(o.freight) maksymalna_freight
	,sum(o.freight) suma_freight 
	,sum(case when o.order_id is not null then 1
	else 0 end) suma_zamowien
	,avg(od.unit_price) srednia_price
	,min(od.unit_price) minimalna_price
	,max(od.unit_price) maksymalna_price
	,sum(od.unit_price) suma_price
from orders o 
join order_details od on o.order_id = od.order_id 
where extract(year from order_date) = 1996
group by extract(quarter from  o.order_date)

/*h. Połącz wyniki z dwóch poprzednich zapytań za pomocą UNION.*/

select
	max(extract(year from order_date)) "year"
	,extract(quarter from  o.order_date) "guarter"
	,avg(o.freight) srednia_freight
	,min(o.freight) minimalna_freight
	,max(o.freight) maksymalna_freight
	,sum(o.freight) suma_freight 
	,sum(case when o.order_id is not null then 1
	else 0 end) suma_zamowien
	,avg(od.unit_price) srednia_price
	,min(od.unit_price) minimalna_price
	,max(od.unit_price) maksymalna_price
	,sum(od.unit_price) suma_price
from orders o 
join order_details od on o.order_id = od.order_id 
where extract(year from order_date) = 1998
group by extract(quarter from  o.order_date)
union all
select 
	min(extract(year from order_date)) "year"
	,extract(quarter from  o.order_date) "guarter"
	,avg(o.freight) srednia_freight
	,min(o.freight) minimalna_freight
	,max(o.freight) maksymalna_freight
	,sum(o.freight) suma_freight 
	,sum(case when o.order_id is not null then 1
	else 0 end) suma_zamowien
	,avg(od.unit_price) srednia_price
	,min(od.unit_price) minimalna_price
	,max(od.unit_price) maksymalna_price
	,sum(od.unit_price) suma_price
from orders o 
join order_details od on o.order_id = od.order_id 
where extract(year from order_date) = 1996
group by extract(quarter from  o.order_date)

/*i. Stwórz to samo zestawienie, co w powyższym zadaniu bez użycia UNION, a modyfikując zapytanie.*/

select
	max(extract(year from order_date)) "year"
	,extract(quarter from  o.order_date) "guarter"
	,avg(o.freight) srednia_freight
	,min(o.freight) minimalna_freight
	,max(o.freight) maksymalna_freight
	,sum(o.freight) suma_freight 
	,sum(case when o.order_id is not null then 1
	else 0 end) suma_zamowien
	,avg(od.unit_price) srednia_price
	,min(od.unit_price) minimalna_price
	,max(od.unit_price) maksymalna_price
	,sum(od.unit_price) suma_price
from orders o 
join order_details od on o.order_id = od.order_id 
where extract(year from order_date) in ('1998', '1996') 
group by extract(quarter from  o.order_date)

/*j. Czy w tabeli występują wielokrotnie te same imiona i nazwiska?*/

select
	c.contact_name
	,count(c.contact_name) 
	,max(extract(year from order_date)) "year"
	,extract(quarter from  o.order_date) "guarter"
	,avg(o.freight) srednia_freight
	,min(o.freight) minimalna_freight
	,max(o.freight) maksymalna_freight
	,sum(o.freight) suma_freight 
	,sum(case when o.order_id is not null then 1
	else 0 end) suma_zamowien
	,avg(od.unit_price) srednia_price
	,min(od.unit_price) minimalna_price
	,max(od.unit_price) maksymalna_price
	,sum(od.unit_price) suma_price
from orders o 
join order_details od on o.order_id = od.order_id 
join customers c on o.customer_id = c.customer_id 
where extract(year from order_date) in ('1998', '1996') 
group by extract(quarter from  o.order_date), c.contact_name

/*k. Stwórz widok, w której dodasz do stworzonej tabeli wiek pracownika oraz staż pracy w miesiącach ( załóżmy, że mamy 1.05.1998). 
Dodaj także zmienną okres wypowiedzenia (jeśli staż jest do 6 miesięcy, wpisz „2 tygodnie”, jeśli staż pracy wynosi od 6 miesięcy do 3 lat „1 miesiąc”, 
jeśli staż pracy wynosi ponad 3 lata wpisz „3 miesiące”).*/

create view v_employee as
select 
	employee_id
	, last_name
	, first_name
	, title, address
	, date_part('year', timestamp'1998-05-01')  - extract(year from birth_date) "age"
	, ((date_part('year', timestamp'1998-05-01')  - extract(year from hire_date)) * 12) + (date_part('month', timestamp'1998-05-01') - extract('month' from hire_date) ) seniority	
	, case when ((date_part('year', timestamp'1998-05-01')  - extract(year from hire_date)) * 12) + (date_part('month', timestamp'1998-05-01') - extract('month' from hire_date)) < 6 then '2 weeks'
	 when ((date_part('year', timestamp'1998-05-01')  - extract(year from hire_date)) * 12) + (date_part('month', timestamp'1998-05-01') - extract('month' from hire_date)) between 6 and 36 then '1 month'
	 when ((date_part('year', timestamp'1998-05-01')  - extract(year from hire_date)) * 12) + (date_part('month', timestamp'1998-05-01') - extract('month' from hire_date)) > 36 then '3 months'
	end period_of_notice
	 from employees e 
	 
select * from v_employee	 
	 
/*l. WYZNACZ ILE PRODUKTÓW MA KAŻDE ZAMÓWIENIE, ILE Z NICH MA FREIGHT >20, WYZNACZ CAŁKOWITĄ KWOTĘ ZAMÓWIENIA, ORAZ LICZBĘ ZAMÓWIEŃ Z RABATEM, A TAKŻE KWOTĘ RABATU KAŻDEGO ZAMÓWIENIA.*/

select * from orders o 

select * from order_details od 

select * from order_details od 

select o.order_id 
	, o.Freight
	, sum(od.Quantity) "suma_produktów_w_zamówieniu"
	, sum(od.unit_price * od.Quantity) "całkowita_kwota_zamówienia"
	, sum(case when od.Discount != 0 then 1 else 0 end) "suma_zamówien_z_rabatem"
	, sum(Case when od.Discount != 0 then od.unit_price * od.Discount else 0 end) "kwota_rabatu"
from orders o
join order_details od on o.order_id  = od.order_id 
group by o.order_id , o.Freight
having o.Freight > 20 and sum(case when od.Discount != 0 then 1 else 0 end) != 0
order by o.order_id

/*3. Język DML:
a. Baza NORTHWIND:*/

select * from employees e 

/*i. Dodaj nowego pracownika, który obejmie stanowisko CEO.*/

insert into employees (employee_id, last_name, first_name, title, title_of_courtesy, birth_date, hire_date, address, city, region, postal_code, country, home_phone, "extension", photo, notes, reports_to, photo_path)
values(10, 'Deep', 'Johnny', 'CEO', 'Mr.', '1963-06-09'::date, '1995-04-09'::date, 'Owensboro', 'Kentucky', 'KY', '98100', 'USA', '(555)555-555-555', '1111', '','Johnny Depp, właśc. John Christopher Depp II – amerykański aktor, scenarzysta, reżyser, producent filmowy i muzyk. Zasłynął w latach 80. dzięki roli w telewizyjnym serialu 21 Jump Street. Uwagę krytyków zwrócił tytułową kreacją w filmie Tima Burtona Edward Nożycoręki.', 2, 'https://pl.wikipedia.org/wiki/Johnny_Depp')

/*ii. Zaktualizuj datę zatrudnienia na pierwszy dzień przyszłego miesiąca*/

update employees 
set hire_date = '1996-05-11'::date
where employee_id = 10

/*iii. Wszystkim pracownikom, którzy mają pole reportsto puste, przypisz id CEO.*/

update employees 
set reports_to  = 0
where reports_to = null

/*iv. Utwórz tabelę tymczasową z zamówień. Uzupełnij puste pola ShipRegion wartością „Brak danych”. Z tabeli tymczasowej usuń dane, gdzie kraj to Switzerland.*/




create or replace view v_order as 
select 
	order_id 
	, customer_id 
	, employee_id 
	, order_date 
	, freight 
	, ship_name 
	, ship_address 
	, coalesce(ship_region,'brak danych') as ship_region 
	, ship_country 
from orders

create or replace view v_order as 
select 
	order_id 
	, customer_id 
	, employee_id 
	, order_date 
	, freight 
	, ship_name 
	, ship_address 
	, coalesce(ship_region,'brak danych') as ship_region 
	, ship_country 
from orders
where ship_country != 'Switzerland'

select * from v_order


/*v. Zaktualizuj dane z poprzedniego zadania (tabeli tymczasowej) podaj SHIPNAME jako NAZWA dostawcy + shipname.*/



create or replace view v_order as 
select 
	 v_order.order_id 
	,  v_order.customer_id 
	,  v_order.employee_id 
	,  v_order.order_date 
	,  v_order.freight 
	,  (s.company_name ||' '||v_order.ship_name ) ship_name
	,  v_order.ship_address 
	,  v_order.ship_region 
	,  v_order.ship_country  
from v_order
join customers c on c.customer_id = v_order.customer_id
join order_details od on od.order_id = v_order.order_id
join products p on od.product_id = p.product_id 
join suppliers s on p.supplier_id = s.supplier_id 

select * from orders o 
select * from order_details od 
select * from products p 
select * from suppliers s 

/*4. Podzapytania / JOIN:
a. Baza Northwind:
i. Wypisz wszystkie zamówienia, które sporządzili pracownicy inni niż Ci z imionami: Janet, Margaret*/

select 
	o.* 
from orders o 
join employees e 
on o.employee_id = e.employee_id 
where e.first_name not in ('Janet', 'Margaret')

/*ii. Wypisz dane wszystkich pracowników (tabela dbo.employees), dopisz do wyników zmienną, będącą liczbą terytoriów, 
 jaką obsługuje pracownik (na podstawie tabeli EmployeeTerritories.*/

select 
	et.territory_id,
	e.* from employees e 
join employee_territories et 
on e.employee_id = et.employee_id 

/*iii. Wypisz unikalne dni zamówienia z tabeli ORDERS, w których nie było zamówienia od pracownika o ID=1*/

select 
	distinct order_date
from orders o 
where employee_id != 1
order by order_date

/*iv. Wyznacz zamówienie wraz z przewoźnikiem i miejscem, przez które będzie przejeżdżać.*/

select * from orders o 
select * from employees e 
select * from employee_territories et 

/*v. Sprawdź ile średnio terytoriów obsługują pracownicy. Wyznacz inne miary określające średnią liczbę terytoriów.*/

create view v_employees_terr
as
select 
	e.employee_id 
	, count(et.territory_id) as count_territory
from employees e 
join employee_territories et 
on e.employee_id = et.employee_id 
group by e.employee_id 

select 
	round(avg(count_territory))
from v_employees_terr 



/*5. CTE:

a. Stwórz tabelę tymczasową z zamówieniami. Dodaj nowe pole – liczba zakupionych produktów. Uzupełnij pole z użyciem CTE.*/

with liczba_zakupionych_cte
as
(select 
	order_id
	, sum(quantity) as liczba_zakupionych_produktow
from order_details od 
group by order_id 
order by order_id )
select lzp.liczba_zakupionych_produktow, o.* from liczba_zakupionych_cte lzp
join orders o on o.order_id = lzp.order_id 


/*b. Dodaj do powyższej tabeli cenę zamówienia oraz imię i nazwisko pracownika odpowiedzialnego za zamówienie – użyj CTE.*/

with liczba_zakupionych_cte
as
(select 
	order_id
	, sum(quantity) as liczba_zakupionych_produktow
from order_details od 
group by order_id 
order by order_id )
select
	lzp.order_id
	, lzp.liczba_zakupionych_produktow
	, e.first_name
	, e.last_name
	,round(sum(od2.unit_price*od2.quantity*(1-od2.discount))) cena_zamowienia 
from liczba_zakupionych_cte lzp
join orders o on o.order_id = lzp.order_id 
join employees e on o.employee_id = e.employee_id 
join order_details od2 on lzp.order_id = od2.order_id 
group by 
	lzp.order_id
	, lzp.liczba_zakupionych_produktow
	, e.first_name
	, e.last_name




/*6. Analiza danych:
a. Analiza HR:
i. Dokonaj analizy pracowników firmy:
1. Sprawdź najlepszych i najgorszych sprzedawców w celu zidentyfikowania pracowników do premii bądź rozmowy kontrolnej.
 (Zbadaj sprzedaż kwotową i sztukową, wykorzystaj różne miary statystyczne – obierz jako punkt odniesienia wartość maksymalną, medianę, średnią itd.)*/

create or replace view v_dane_sprzedaz as 
select
o.employee_id 
,round(sum(od.unit_price *od.quantity *(1-od.discount))::numeric) as sprzedaz
from orders o 
join order_details od 
on o.order_id =od.order_id 
group by o.employee_id
order by o.employee_id

create view v_percentyl as
select 
percentile_disc(0.1) within group (order by sprzedaz) perc_10
,percentile_disc(0.5) within group (order by sprzedaz) perc_50
,percentile_disc(0.9) within group (order by sprzedaz) perc_90
from v_dane_sprzedaz

create or replace view v_ocena_koncowa as
select *, 
case 
	when sprzedaz<perc_10 then 'do zwolnienia'
	when sprzedaz>= perc_10 and sprzedaz < perc_50 then 'program naprawczy'
	when sprzedaz>=perc_50 and sprzedaz < perc_90 then 'mozesz lepiej'
	when sprzedaz>=perc_90 then 'tak trzymaj'
	else '4'
end premia
from v_dane_sprzedaz 
cross join v_percentyl 

select
employee_id
,premia
from v_ocena_koncowa

/*2. Sprawdź czy pracownicy niedługo osiągną wiek emerytalny.*/

select 
	employee_id
	, first_name||' '||last_name
	, birth_date
	, extract (year from current_date) - extract(year from birth_date) "age"
	, case 	when extract (year from current_date) - extract(year from birth_date)  > 65 then 'na emeryturze'
			when extract (year from current_date) - extract(year from birth_date) between 60 and 65 then 'ochrona przed przejsciem na emeryture'
			else 'jeszcze troche popracuje zanim bedzie mogl pojsc na emeryture' end status_emerytalny
from employees e 


/*3. Sprawdź czy któraś płeć przeważa nad inną.*/

select 
	count(*)
	,case 	when title_of_courtesy in ('Ms.', 'Mrs.') then 'kobieta'
			when title_of_courtesy in ('Dr.', 'Mr.') then 'Mezczyzna'
			end plec
from employees e 
group by case when title_of_courtesy in ('Ms.', 'Mrs.') then 'kobieta'
			when title_of_courtesy in ('Dr.', 'Mr.') then 'Mezczyzna'
			end 


/*4. Sprawdź średni czas pracy (od kiedy są zatrudnieni) w firmie. Czy istnieje ryzyko, że większość pracowników niebawem się zwolni?*/

select 
	employee_id
	, first_name||' '||last_name imie_i_nazwisko
	, hire_date
	, extract (year from current_date) - extract(year from hire_date) "lata_przepracowane"
	, case 	when extract (year from current_date) - extract(year from hire_date)  >= 28  then 'male_ryzyko'
			when extract (year from current_date) - extract(year from hire_date) between 25 and 28 then 'srednie_ryzyko'
			else 'duze_ryzyko' end status_checi_zmiany_pracy_przez_pracownika
from employees e 
