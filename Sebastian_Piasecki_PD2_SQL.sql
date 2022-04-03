/*Za pomocą funkcji okna wyznacz dla każdego zamówienia z tabeli orders, średnią oraz medianę zamówień z bieżącego roku-miesiąca. 
 Dodaj do wyników kolumnę z informacją czy dane zamówienie ma kwotę wyższą czy mniejszą lub równą od średniej oraz mediany.
 Następne za pomocą funkcji agregujących stwórz zestawienie według roku-miesiąca z liczbą zamówień powyżej/poniżej średniej /mediany. */


create view srednie_wyliczenia as
select distinct  
	o.order_id 
	, to_char(o.order_date, 'yyyy-mm' ) as czas
	, sum(od.unit_price * od.quantity * (1-od.discount)) over (partition by o.order_id) as suma_zamowienia
	, avg(od.unit_price * od.quantity * (1-od.discount)) over ( partition by o.order_id) as srednia_zamowienia
from orders o 
join order_details od 
on o.order_id = od.order_id
order by 1


create view mediana_wyliczenie as
select 
czas,
round(percentile_disc(0.5) within group (order by suma_zamowienia)) as mediana
from srednie_wyliczenia
group by czas


create view v_przed_ostatnia_tabela as
select 
	sw.order_id
	, sw.czas
	, sw.suma_zamowienia
	, sw.srednia_zamowienia
	, mw.mediana
	, (od.unit_price * od.quantity * (1-od.discount)) zamowienie
	, case when sw.srednia_zamowienia < (od.unit_price * od.quantity * (1-od.discount)) then 'srednia_mniejsza'
		 when sw.srednia_zamowienia = (od.unit_price * od.quantity * (1-od.discount)) then 'srednia_rowna'
		 when sw.srednia_zamowienia > (od.unit_price * od.quantity * (1-od.discount)) then 'srednia_wieksza'
		 end srednia_do_zamowienia
	, case when mw.mediana < (od.unit_price * od.quantity * (1-od.discount)) then 'mediana_mniejsza'
		 when mw.mediana = (od.unit_price * od.quantity * (1-od.discount)) then 'mediana_rowna'
		 when mw.mediana > (od.unit_price * od.quantity * (1-od.discount)) then 'mediana_wieksza'
		 end mediana_do_zamowienia
from srednie_wyliczenia sw
join mediana_wyliczenie mw on sw.czas = mw.czas
join orders o on sw.order_id = o.order_id 
join order_details od on o.order_id = od.order_id

select 
	 czas
	, count(*)
	, srednia_do_zamowienia
from v_przed_ostatnia_tabela
group by czas, srednia_do_zamowienia
order by czas

select 
	 czas
	, count(*)
	, mediana_do_zamowienia
from v_przed_ostatnia_tabela
group by czas, mediana_do_zamowienia
order by czas