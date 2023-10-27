#操作和逻辑处理
#1、管理员发布新活动公告，设置营销活动等
insert into notice_tab values (7,'520礼品大优惠','https://qqcloud.com/notice7.html','2022-05-23 10:00:21','0','2022-05-15 00:00:01','2022-05-20 23:59:59','ADM111');
insert into activities_tab(act_id,act_date,act_type,act_limit,act_discount,act_start,act_end,act_stat) 
	values(4,'2022-05-23 12:01:01','1',100,20.00,'2022-5-18 00:00:01','2022-05-20 23:59:59','1'); #在5.18-5.20期间满100减20

#2、员工更新某产品库存，在原有基础上新增20个；在一个已有的产品类型下操作一个新的产品入库并上架可见，设置商品活动折扣率等
update product_tab set stock_quan=stock_quan+20 where pro_id=1;
insert into product_tab values('辣椒粉',77,500,0,'https://qq.com/store/辣椒粉.jpg',13,30,0.1,32,13*0.6,7,3988007,'2022-05-23 10:00:00','1');

#3、一个新客户浏览商品，并打算购买，新注册了用户名，同时新增了一条默认的收货地址
#浏览商品时：1、体现偏好，2、浏览的sql语句
select * from v_products; #客户浏览产品使用view
insert into customer_tab values ("好啦小猫","12342300240037899","wr7yf7Sedsq",100020,0,"零食、海鲜");
insert into customer_ext_tab values(24,100020,"昵称1","东南小区1号101","17310984556",2,"1");

#4、该客户浏览商品，并根据需要选择商品进购物车
#浏览商品时：1、体现偏好，2、浏览的sql语句
select * from v_products; #客户浏览产品使用view
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (21, 1, 0.00,1,NULL,100020,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (22, 1, 0.00,2,NULL,100020,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (23, 1, 0.00,5,NULL,100020,'0');

#5、客户浏览购物车，调整所选商品
#浏览购物车SQL,根据所选物品匹配营销活动表
update cart_tab set total_number=2 where car_id=21;
delete from cart_tab where car_id=23;

#6、客户点击购买生成订单，订单会根据营销活动表数据和购物车明细数据计算订单总价
select * from activities_tab where act_stat='1';  #遍历活动营销表进行打折金额或积分计算
INSERT INTO order_tab(ord_id,express_num,ord_time,ord_price,discount,deliver_fee,ord_quan,points,ord_ext_id,st_id,ord_stat) 
			VALUES (5, NULL, '2022-05-23 10:13:22', 56.00, 0.00, 6,3, '1.50', 24, NULL, '0');
update cart_tab set car_stat='1',ord_id=5 where car_id in (21,22) and cus_id=100020 and ord_id is NULL; #此步骤也可以通过设计触发器完成

#7、客户浏览订单（明细），并修改数量
update cart_tab set total_number=1 where car_id=21;
update order_tab set ord_quan=2,ord_price=37,points='1.00',deliver_fee=6 where ord_id=5;  #此步骤也可以通过设计触发器完成

#8、客户确认订单，待支付，订单发生变化
update order_tab set ord_stat='1' where ord_id=5; 

#9、客户选择支付方式并支付，订单发生变化，记录支付明细(一次性成功，实际可能会失败退回重付等异常，需要通过系统避免重复支付的可能性)
update order_tab set ord_stat='2' where ord_id=5; 
INSERT INTO activities_tab(act_id,act_date,act_type,act_stat,act_amount,act_confirm,ord_id,act_code) 	
	VALUES(5,'2022-05-23 10:12:22','1','1',62.00,'0',5,'ZFB1234567894');

#10、系统自动或内勤员工操作，分配快递单号、快递员工
update order_tab set express_num='202205230000001',st_id=3350001,ord_stat='3' where ord_id=5; 

#11、送达客户，系统自动或快递员工操作更新订单状态
update order_tab set ord_stat='4' where ord_id=5; 

#12、客户评论本次订单服务
insert into comment_tab values ("物流很快，小哥很Nice，谢谢",1,'2022-05-24 13:30:48',100003,5);
update order_tab set ord_stat='5' where ord_id=5;   #此步骤也可以通过设计触发器完成


-- ----------------------------
-- Test_Queries
-- ----------------------------  

# 货物和种类
#1 看看昨天卖出去了什么？ 假设今天是11号，寻找昨天10号的订单 
select t.type_name as "Category" , c.total_number as "Quantity" , p.pro_name as "Product" , o.ord_id
from order_tab as o 
join cart_tab as c on c.ord_id = o.ord_id
join product_tab as p on c.pro_id = p.pro_id
join type_tab as t on t.type_id = p.type_id
where day(o.ord_time) = 10 ;

#2 看看哪一个种类的商品最受欢迎？假设受欢迎程度是货物买出去的数量
select t.type_name as "Category" , sum(c.total_number) as "Quantity" 
from order_tab as o 
join cart_tab as c on c.ord_id = o.ord_id
join product_tab as p on c.pro_id = p.pro_id
join type_tab as t on t.type_id = p.type_id
group by t.type_name  
order by Quantity desc ; 

#3 看看哪一个种类的商品最能够赚取收入？
select t.type_name as "Category" , sum((c.total_number*p.price)) as Revenue 
from order_tab as o 
join cart_tab as c on c.ord_id = o.ord_id
join product_tab as p on c.pro_id = p.pro_id
join type_tab as t on t.type_id = p.type_id 
group by t.type_name 
order by Revenue desc ;

# 财务方向
#4 累计总收入是多少？ 
select sum(ord_price) as "Total Revenue"
from order_tab ;

#5 总采购成本和毛利率是多少？ 顺便计算其毛利率
select sum(distinct o.ord_price) as "Total Revenue" , sum(c.total_number*p.prime_cost) as "Purchase Cost" , 
(sum(distinct o.ord_price)-sum(c.total_number*p.prime_cost)) as "Gross Profit" , 
(sum(distinct o.ord_price)-sum(c.total_number*p.prime_cost))/sum(distinct o.ord_price) as "Gross Profit Margin" 
from order_tab as o 
join cart_tab as c on c.ord_id = o.ord_id
join product_tab as p on c.pro_id = p.pro_id ; 

#6 计算运费总额 和 运费占总收入的占比
select sum(deliver_fee) as "Total Delivery Charges" ,
sum(ord_price) as "Total Revenue" , sum(deliver_fee)/sum(ord_price) as "Delivery Charges Percentage"
from order_tab ; 

# 客户方面
#7 计算总客户人数，有下单的客户人数
select count(distinct cus_id) as "Customer Register" 
from customer_tab as c ;

#8 有下单的客户人数
select count(distinct ord_ext_id) as "Number of Customer makes Order"
from order_tab ;

#9.计算每位客户的每日购买额，并根据客户每天的购买额对客户进行排名。将没有产生任何购买的客户的购买额设置为0。
WITH tempTb1 as (
select ct.cus_id,date(od.ord_time) OrderDate,sum(od.ord_price*(1-od.discount)) as orderprice,count(distinct od.ord_id) as ordernum 
from order_tab od,customer_ext_tab ct where od.ord_ext_id=ct.ext_id
group by date(od.ord_time),ct.cus_id)
select a.date1,a.cus_name,a.cus_id,coalesce(b.orderprice,0) as price,
RANK( ) OVER ( 
  PARTITION BY a.date1 
  ORDER BY b.orderprice DESC
 ) sales_rank  
from (select distinct date(ord_time) as date1,b1.*  from order_tab a1,customer_tab b1) a 
left join tempTb1 b on a.cus_id=b.cus_id and a.date1=b.OrderDate;


#库存管理方面
#10看现在的库存状况 少于十个的需要订货 和对应的供应商
select pro_name , stock_quan , sup_name , sup_tel
from product_tab as p 
join supplier_tab as s on s.sup_id = p.sup_id
having stock_quan < 10 
order by stock_quan asc ;

#11 看看有没有货物临近过期 
select pro_id , pro_name , pro_date , shelf_life , date(now()) as "Today"
from product_tab
where datediff(now(), pro_date) >shelf_life;

#12 查询物料的最新采购价格，如果同一日期有多个价格取最小值
select * from (
    select pro_id,p_store_date,price_in,
    row_number() over(partition by pro_id order by pro_id asc,p_store_date desc,price_in asc) row_num
    from product_store_tab) t1
where t1.row_num=1;
