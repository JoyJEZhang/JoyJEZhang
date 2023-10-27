#SQL小组作业 2022-05-20
create database if not exists grocery;
use grocery;

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for comment   评论表信息
-- ----------------------------
drop table if exists comment_tab;        #使用_tab用作数据表的命名规范#
create table comment_tab
	(com_content		varchar(400),   #最多评论400个字符长度#
	 com_type		varchar(1),         #1好评，2差评，3中评#
	 com_time		datetime,           #评论时间
     com_id         int NOT NULL AUTO_INCREMENT ,    
     ord_id       int  NOT NULL,      #评论关联的订单ID
	 primary key (com_id),
     foreign key (ord_id) references order_tab (ord_id)  #和订单表关联#
		 ON DELETE RESTRICT ON UPDATE RESTRICT
	);

-- ----------------------------
-- Table structure for customer   客户表信息
-- ----------------------------
drop table if exists customer_tab;
create table customer_tab
	(cus_name		    varchar(20) NOT NULL, #用户名最多20个字符长度#
	 cus_account		 varchar(20), #用户银行账号#
     cus_code              varchar(16) NOT NULL,  #密码最多16个字符长度#
     cus_id                  int NOT NULL AUTO_INCREMENT,
     total_points         numeric(7,0), #客户积分总数
     preference          varchar(50),  #客户偏好
     
	 primary key (cus_id)
	);

-- ----------------------------
-- Table structure for customer_ext  收货人表信息
-- ----------------------------
drop table if exists customer_ext_tab;    
create table customer_ext_tab
    (
     ext_id               int NOT NULL AUTO_INCREMENT,
     cus_id               int NOT NULL, #同一个客户ID可以有多条收货信息
     cus_name         varchar(20),  #收货人姓名#              ,新增
     cus_add	        varchar(20),  #收货人地址#
	 cus_tel              varchar(20),  #联系电话#
     cus_dist            numeric(6,2), #距离#
     cus_addtype        varchar(1), #1指默认地址#
      primary key (ext_id),
      foreign key (cus_id) references customer_tab (cus_id)  #和客户表关联#
		 ON DELETE RESTRICT ON UPDATE RESTRICT
     );

-- ----------------------------
-- Table structure for order  订单表信息
-- ---------------------------- 
DROP TABLE IF EXISTS order_tab;
CREATE TABLE order_tab  (
  ord_id int NOT NULL AUTO_INCREMENT,
  express_num varchar(15),  #快递号
  ord_time datetime NOT NULL,   #订单时间
  ord_price numeric(10, 2) NOT NULL, #订单价格
  discount numeric(5,4) NULL DEFAULT NULL,  #折扣
  deliver_fee numeric(10, 2),  #运费
  ord_quan numeric(7, 0),  #订单下的商品总数
  points varchar(120),  #订单积分点
  ord_ext_id int NOT NULL,  #客户收货信息ID
  st_id int,  #分配的内勤比如快递员工ID         ， 新增
  ord_stat varchar(1) NOT NULL,  #订单状态：0-新产品订单，1-支付中，2-完成支付，3-运送中，4-已送达、待确认，5-待评价，6-已完成，8-订单售后，9-取消订单           ， 新增
  PRIMARY KEY (ord_id),
  FOREIGN KEY (ord_ext_id) REFERENCES customer_ext_tab (ext_id) ON DELETE RESTRICT ON UPDATE RESTRICT, #和收货人表关联#
  FOREIGN KEY (st_id) REFERENCES staff_tab (st_id) on delete set null   #和内勤表关联#
);


-- ----------------------------
-- Table structure for cart  购物车明细表
-- ----------------------------
DROP TABLE IF EXISTS cart_tab;
CREATE TABLE cart_tab  (
  car_id int NOT NULL AUTO_INCREMENT,
  total_number int NOT NULL,      #产品数量
  discount numeric(5,4) NULL DEFAULT 0,  #折扣                   ，新增
  pro_id int NOT NULL,                 #产品ID
  ord_id int NULL DEFAULT NULL,        #订单ID,新增   未产生订单前，字段值为空，stat=0;  产生订单后，字段值为订单ID，stat=1
  cus_id int NOT NULL,  #客户ID  ， 新增
  car_stat varchar(1) NOT NULL , #购物车产品状态：0-加入购物车，1-已产生订单，8-售后                    ， 新增
  PRIMARY KEY (car_id),
  FOREIGN KEY (pro_id) REFERENCES product_tab (pro_id) ON DELETE RESTRICT ON UPDATE RESTRICT,   #和产品表关联#
  FOREIGN KEY (cus_id) REFERENCES customer_tab (cus_id) ON DELETE RESTRICT ON UPDATE RESTRICT, #和客户表关联#
  FOREIGN KEY (ord_id) REFERENCES order_tab (ord_id) on delete set null #和订单表关联#
);

-- ----------------------------
-- Table structure for pay_tab 订单支付明细表
-- ----------------------------		
drop table if exists pay_tab; 
create table pay_tab
	(pay_id    int  NOT NULL AUTO_INCREMENT,
	pay_date datetime not null,   #操作时间
	pay_type varchar(1) NOT NULL,              #支付类型 0-银行卡直接支付，1-微信支付，2-支付宝支付，3-银联闪付，支付渠道可扩展，暂列以上
	pay_stat varchar(1) NOT NULL,               #支付状态 0-待支付，1支付成功，2-支付失败，2-退款
	pay_amount numeric(12,2) NOT NULL,   #支付金额  对应订单的总金额
	pay_confirm varchar(1),        #财务对账状态  0-财务未确认，1-财务已确认
	ord_id int NOT NULL,        #订单ID
	pay_code varchar(50) NOT NULL,        #支付单号 用以和银行等支付机构对账
	primary key(pay_id),
	FOREIGN KEY (ord_id) REFERENCES order_tab (ord_id) ON DELETE RESTRICT ON UPDATE RESTRICT  #和订单表关联#
	);

-- ----------------------------
-- Table structure for product_tab  产品表信息
-- ----------------------------
drop table if exists product_tab;        
create table product_tab
	(pro_name		varchar(400) NOT NULL,   #商品名称
	 pro_id		    int NOT NULL AUTO_INCREMENT,        
	 pro_weig		numeric(7,2),  #单位重量 克
     return_quan    numeric(7,0),   #退货数量
	 pro_pic        varchar(200) ,  #指向图片介绍的存储位置，图片这种静态资源预先存在制定的共享目录下#
     price          numeric(7,2),    #单价
     shelf_life     numeric(7,0),     #产品保质期 天
     life_discount  numeric(7,5),  #临保折扣因为是%，所以要小数点后多一点位
     stock_quan     numeric(7,0),  #库存数量
     prime_cost     numeric(7,2),   #单位成本
     type_id       int NOT NULL,  #产品类型
     sup_id   int NOT NULL,   #供货商ID        ，新增
     pro_date   datetime NOT NULL,  #上架时间       ，新增
     sup_stat   varchar(1) NOT NULL,   #是否销售状态，1表示上架销售中，0表示当前不可销售       ，新增
	 primary key (pro_id),
	 foreign key (type_id) references type_tab (type_id)  #和客户表关联#
		 ON DELETE RESTRICT ON UPDATE RESTRICT,
	 foreign key (sup_id) references supplier_tab(sup_id)  #和供应商表关联#
		 ON DELETE RESTRICT ON UPDATE RESTRICT
     );

-- ----------------------------
-- Table structure for type_tab    产品分类表信息
-- ----------------------------
drop table if exists type_tab;
create table type_tab
	(type_id       int NOT NULL AUTO_INCREMENT,
     type_name      varchar(10) NOT NULL,
 	 primary key (type_id)
	);

-- ----------------------------
-- Table structure for staff_tab     内勤信息表
-- ----------------------------
drop table if exists staff_tab;
create table staff_tab
	(st_job varchar(50),
	 st_add varchar(200),
	 st_id    int NOT NULL AUTO_INCREMENT,
	 st_tel   varchar(20),
	 st_name varchar(50) NOT NULL ,
	 para_st_id int,             #上级的员工ID
	 primary key (st_id)
	 );

-- ----------------------------
-- Table structure for supplier_tab  供应商表信息
-- ----------------------------
drop table if exists supplier_tab;
create table supplier_tab
	 (sup_add  varchar(200),
	  sup_tel  varchar(20),
	  sup_id   int NOT NULL AUTO_INCREMENT,
	  sup_name varchar(50) NOT NULL ,
	  contract_name varchar(50) ,  #联系人  ,新增
	  primary key(sup_id)
	 );

-- ----------------------------
-- Table structure for administrator_tab   系统管理员
-- ----------------------------
drop table if exists administrator_tab; 
create table administrator_tab
	(
	adm_name varchar(20), #管理员用户名
	adm_code varchar(8), #管理员密码
	adm_level varchar(1), #管理员等级  1-最高权限,2-普通管理 ，新增
	st_id int  NOT NULL,
	primary key (adm_name),
	foreign key (st_id) references staff_tab(st_id)  #和内勤表关联#
		 ON DELETE RESTRICT ON UPDATE RESTRICT
	);

-- ----------------------------
-- Table structure for notice_tab  公告版
-- ----------------------------	
drop table if exists notice_tab; 
create table notice_tab
	(note_id int  NOT NULL AUTO_INCREMENT,
	note_head varchar(50),   #标题
	note_content varchar(500),  #具体内容
	note_time datetime not null,
	note_type varchar(1),   #公告类型 0-活动，1-运维，2-通知
	note_start datetime,    #生效时间           ，新增
	note_end  datetime,   #结束时间           ，新增
	note_admname varchar(20) not null,                  #操作人           ，新增
	primary key (note_id) ,
	foreign key (note_admname) references administrator_tab(adm_name)  #和管理员表关联#
		 ON DELETE RESTRICT ON UPDATE RESTRICT
	);

-- ----------------------------
-- Table structure for activities_tab   活动营销表
-- ----------------------------		
drop table if exists activities_tab; 
create table activities_tab
	(act_id    int  NOT NULL AUTO_INCREMENT,
	act_date datetime not null,
	act_type varchar(1) not null, #活动类型   0-满减，1-折扣率，2-积分倍率
	act_limit numeric(10,2),        #条件值
	act_discount numeric(10,4), #满足条件值，根据活动类型扣减或打折
	act_start datetime,    #生效时间           ，新增
	act_end  datetime,   #结束时间           ，新增
	act_stat varchar(1) not null, #活动状态   0-无效，1-有效，
	primary key(act_id)
	);
    
    #创建产品库存表# 新增
    drop table if exists product_store_tab;        
create table product_store_tab
	(
	 p_store_id		    int NOT NULL AUTO_INCREMENT,   #商品今进货批次ID  
	 pro_id		    int NOT NULL ,    #商品ID
	 price_in          numeric(7,2),    #进货单价
     stock_quan     numeric(7,0),  #进货数量
     type_id       int NOT NULL,  #产品类型
     sup_id   int NOT NULL,   #供货商ID 
     p_store_date   datetime NOT NULL,  #进货时间 
     primary key (p_store_id),
     FOREIGN KEY (pro_id) REFERENCES product_tab (pro_id) ON DELETE RESTRICT ON UPDATE RESTRICT,   #和产品表关联#
	 foreign key (type_id) references type_tab (type_id)  #和客户表关联#
		 ON DELETE RESTRICT ON UPDATE RESTRICT,
	 foreign key (sup_id) references supplier_tab(sup_id)  #和供应商表关联#
		 ON DELETE RESTRICT ON UPDATE RESTRICT
     );

-- ----------------------------
-- View structure for product_tab   产品表view
-- ----------------------------		
drop view if exists v_products; 
create view v_products as
	select * from product_tab;
    
-- ----------------------------
-- Records of type_tab
-- ----------------------------    
insert into type_tab values (1, "蔬菜豆制品"); 
insert into type_tab values (2, "肉禽蛋");
insert into type_tab values (3, "海鲜"); 
insert into type_tab values (4, "水果"); 
insert into type_tab values (5, "乳制品"); 
insert into type_tab values (6, "熟食"); 
insert into type_tab values (7, "粮油调味"); 
insert into type_tab values (8, "饮料"); 
insert into type_tab values (9, "零食"); 

-- ----------------------------
-- Records of staff_tab
-- ----------------------------    
insert into staff_tab values 
('deliver','SUFE',3350001,'13354837001','Abigail',2437001),
('deliver','SUFE',3350002,'13354837002','Ada',3350001),
('deliver','SUFE',3350003,'13354837003','Adela',3350001),
('deliver','SUFE',3350004,'13354837004','Adelaide',3350001),
('deliver','SUFE',3350005,'13354837005','Afra',3350001),
('deliver','SUFE',3350006,'13354837006','Agatha',3350001),
('administrator','FDUE',2364001,'12364600001','Alma',2437001),
('administrator','FDUE',2364002,'12364600002','Alva',2364001),
('administrator','FDUE',2364003,'12364600003','Amanda',2364001),
('manager','TJUE',2437001,'16262437001','Annabeele',NULL),
('sorting','SISU',7678001,'17678464001','Belinda',2437001),
('sorting','SISU',7678002,'17678464002','Bella',7678001),
('sorting','SISU',7678003,'17678464003','Bernice',7678001),
('sorting','SISU',7678004,'17678464004','Bertha',7678001),
('sorting','SISU',7678005,'17678464005','Beryl',7678001),
('sorting','SISU',7678006,'17678464006','Bess',7678001);

-- ----------------------------
-- Records of supplier_tab
-- ----------------------------   
 insert into supplier_tab values 
('ADDR01','12539880001',3988001,'Exotic Liquids','Bblythe'),
('ADDR02','12539880002',3988002,'Tokyo Traders','Bonnie'),
('ADDR03','12539880003',3988003,'Pavlova, Ltd.','Bridget'),
('ADDR04','12539880004',3988004,'Specialty Biscuits, Ltd.','Camille'),
('ADDR05','12539880005',3988005,'PB Knckebrd AB','Candice'),
('ADDR06','12539880006',3988006,'Hema Ltd.','Cara'),
('ADDR07','12539880007',3988007,'Dingdong Ltd.','Carol'),
('ADDR08','12539880008',3988008,'Mayi Ltd.','Caroline'),
('ADDR09','12539880009',3988009,'LV Ltd.','Catherine'),
('ADDR10','12539880010',3988010,'No1 Ltd.','Cathy'),
('ADDR11','12539880011',3988011,'No2 Ltd.','Cecilia'),
('ADDR12','12539880012',3988012,'No3 Ltd.','Celeste'),
('ADDR13','12539880013',3988013,'No4 Ltd.','Charlotte'),
('ADDR14','12539880014',3988014,'No5 Ltd.','Cherry'),
('ADDR15','12539880015',3988015,'No6 Ltd.','Cheryl'),
('ADDR16','12539880016',3988016,'Bigfoot Breweries','Chloe'),
('ADDR17','12539880017',3988017,'Svensk Sjfda AB','Claire'),
('ADDR18','12539880018',3988018,'Leka Trading','Constance'),
('ADDR19','12539880019',3988019,'Kela Trading','Cora'),
('ADDR20','12539880020',3988020,'SH Trading','Crystal') ;

-- ----------------------------
-- Records of product_tab
-- ----------------------------    
insert into product_tab values('苹果汁',1,500,0,'https://qq.com/store/苹果汁.jpg',18,30,0.1,39,18*0.6,8,3988001,'2022-05-01 10:00:00','1');
insert into product_tab values('牛奶',2,500,0,'https://qq.com/store/牛奶.jpg',19,30,0.1,17,19*0.6,8,3988001,'2022-05-01 10:00:00','1');
insert into product_tab values('蕃茄酱',3,500,0,'https://qq.com/store/蕃茄酱.jpg',10,30,0.1,13,10*0.6,7,3988001,'2022-05-01 10:00:00','1');
insert into product_tab values('盐',4,500,0,'https://qq.com/store/盐.jpg',22,30,0.1,53,22*0.6,7,3988001,'2022-05-01 10:00:00','1');
insert into product_tab values('麻油',5,500,0,'https://qq.com/store/麻油.jpg',21.35,30,0.1,0,21.35*0.6,7,3988001,'2022-05-01 10:00:00','1');
insert into product_tab values('酱油',6,500,0,'https://qq.com/store/酱油.jpg',25,30,0.1,120,25*0.6,7,3988001,'2022-05-01 10:00:00','1');
insert into product_tab values('海鲜粉',7,500,0,'https://qq.com/store/海鲜粉.jpg',30,30,0.1,15,30*0.6,7,3988001,'2022-05-01 10:00:00','1');
insert into product_tab values('胡椒粉',8,500,0,'https://qq.com/store/胡椒粉.jpg',40,30,0.1,6,40*0.6,7,3988001,'2022-05-01 10:00:00','1');
insert into product_tab values('鸡',9,500,0,'https://qq.com/store/鸡.jpg',97,30,0.1,29,97*0.6,2,3988002,'2022-05-01 10:00:00','1');
insert into product_tab values('蟹',10,500,0,'https://qq.com/store/蟹.jpg',31,30,0.1,31,31*0.6,3,3988002,'2022-05-01 10:00:00','1');
insert into product_tab values('大众奶酪',11,500,0,'https://qq.com/store/大众奶酪.jpg',21,30,0.1,22,21*0.6,5,3988002,'2022-05-01 10:00:00','1');
insert into product_tab values('德国奶酪',12,500,0,'https://qq.com/store/德国奶酪.jpg',38,30,0.1,86,38*0.6,5,3988003,'2022-05-01 10:00:00','1');
insert into product_tab values('龙虾',13,500,0,'https://qq.com/store/龙虾.jpg',6,30,0.1,24,6*0.6,3,3988003,'2022-05-01 10:00:00','1');
insert into product_tab values('沙茶',14,500,0,'https://qq.com/store/沙茶.jpg',23.25,30,0.1,35,23.25*0.6,7,3988004,'2022-05-01 10:00:00','1');
insert into product_tab values('味精',15,500,0,'https://qq.com/store/味精.jpg',15.5,30,0.1,39,15.5*0.6,7,3988004,'2022-05-01 10:00:00','1');
insert into product_tab values('饼干',16,500,0,'https://qq.com/store/饼干.jpg',17.45,30,0.1,29,17.45*0.6,9,3988004,'2022-05-01 10:00:00','1');
insert into product_tab values('猪肉',17,500,0,'https://qq.com/store/猪肉.jpg',39,30,0.1,0,39*0.6,2,3988005,'2022-05-01 10:00:00','1');
insert into product_tab values('墨鱼',18,500,0,'https://qq.com/store/墨鱼.jpg',62.5,30,0.1,42,62.5*0.6,3,3988006,'2022-05-01 10:00:00','1');
insert into product_tab values('糖果',19,500,0,'https://qq.com/store/糖果.jpg',9.2,30,0.1,25,9.2*0.6,9,3988006,'2022-05-01 10:00:00','1');
insert into product_tab values('桂花糕',20,500,0,'https://qq.com/store/桂花糕.jpg',81,30,0.1,40,81*0.6,9,3988007,'2022-05-01 10:00:00','1');
insert into product_tab values('花生',21,500,0,'https://qq.com/store/花生.jpg',10,30,0.1,3,10*0.6,9,3988007,'2022-05-01 10:00:00','1');
insert into product_tab values('糯米',22,500,0,'https://qq.com/store/糯米.jpg',21,30,0.1,104,21*0.6,7,3988007,'2022-05-01 10:00:00','1');
insert into product_tab values('燕麦',23,500,0,'https://qq.com/store/燕麦.jpg',9,30,0.1,61,9*0.6,7,3988008,'2022-05-01 10:00:00','1');
insert into product_tab values('汽水',24,500,0,'https://qq.com/store/汽水.jpg',4.5,30,0.1,20,4.5*0.6,8,3988008,'2022-05-01 10:00:00','1');
insert into product_tab values('巧克力',25,500,0,'https://qq.com/store/巧克力.jpg',14,30,0.1,76,14*0.6,9,3988008,'2022-05-01 10:00:00','1');
insert into product_tab values('棉花糖',26,500,0,'https://qq.com/store/棉花糖.jpg',31.23,30,0.1,15,31.23*0.6,9,3988008,'2022-05-01 10:00:00','1');
insert into product_tab values('牛肉干',27,500,0,'https://qq.com/store/牛肉干.jpg',43.9,30,0.1,49,43.9*0.6,9,3988008,'2022-05-01 10:00:00','1');
insert into product_tab values('烤肉酱',28,500,0,'https://qq.com/store/烤肉酱.jpg',45.6,30,0.1,26,45.6*0.6,7,3988009,'2022-05-01 10:00:00','1');
insert into product_tab values('鸭肉',29,500,0,'https://qq.com/store/鸭肉.jpg',123.79,30,0.1,0,123.79*0.6,2,3988010,'2022-05-01 10:00:00','1');
insert into product_tab values('黄鱼',30,500,0,'https://qq.com/store/黄鱼.jpg',25.89,30,0.1,10,25.89*0.6,3,3988010,'2022-05-01 10:00:00','1');
insert into product_tab values('温馨奶酪',31,500,0,'https://qq.com/store/温馨奶酪.jpg',12.5,30,0.1,0,12.5*0.6,5,3988011,'2022-05-01 10:00:00','1');
insert into product_tab values('白奶酪',32,500,0,'https://qq.com/store/白奶酪.jpg',32,30,0.1,9,32*0.6,5,3988011,'2022-05-01 10:00:00','1');
insert into product_tab values('浪花奶酪',33,500,0,'https://qq.com/store/浪花奶酪.jpg',2.5,30,0.1,112,2.5*0.6,5,3988011,'2022-05-01 10:00:00','1');
insert into product_tab values('啤酒',34,500,0,'https://qq.com/store/啤酒.jpg',14,30,0.1,111,14*0.6,8,3988011,'2022-05-01 10:00:00','1');
insert into product_tab values('蜜桃汁',35,500,0,'https://qq.com/store/蜜桃汁.jpg',18,30,0.1,20,18*0.6,8,3988011,'2022-05-01 10:00:00','1');
insert into product_tab values('鱿鱼',36,500,0,'https://qq.com/store/鱿鱼.jpg',19,30,0.1,112,19*0.6,3,3988012,'2022-05-01 10:00:00','1');
insert into product_tab values('干贝',37,500,0,'https://qq.com/store/干贝.jpg',26,30,0.1,11,26*0.6,3,3988012,'2022-05-01 10:00:00','1');
insert into product_tab values('绿茶',38,500,0,'https://qq.com/store/绿茶.jpg',263.5,30,0.1,17,263.5*0.6,8,3988012,'2022-05-01 10:00:00','1');
insert into product_tab values('运动饮料',39,500,0,'https://qq.com/store/运动饮料.jpg',18,30,0.1,69,18*0.6,8,3988012,'2022-05-01 10:00:00','1');
insert into product_tab values('虾米',40,500,0,'https://qq.com/store/虾米.jpg',18.4,30,0.1,123,18.4*0.6,3,3988012,'2022-05-01 10:00:00','1');
insert into product_tab values('虾子',41,500,0,'https://qq.com/store/虾子.jpg',9.65,30,0.1,85,9.65*0.6,3,3988012,'2022-05-01 10:00:00','1');
insert into product_tab values('糙米',42,500,0,'https://qq.com/store/糙米.jpg',14,30,0.1,26,14*0.6,7,3988013,'2022-05-01 10:00:00','1');
insert into product_tab values('柳橙汁',43,500,0,'https://qq.com/store/柳橙汁.jpg',46,30,0.1,17,46*0.6,8,3988013,'2022-05-01 10:00:00','1');
insert into product_tab values('蚝油',44,500,0,'https://qq.com/store/蚝油.jpg',19.45,30,0.1,27,19.45*0.6,7,3988014,'2022-05-01 10:00:00','1');
insert into product_tab values('雪鱼',45,500,0,'https://qq.com/store/雪鱼.jpg',9.5,30,0.1,5,9.5*0.6,3,3988014,'2022-05-01 10:00:00','1');
insert into product_tab values('蚵',46,500,0,'https://qq.com/store/蚵.jpg',12,30,0.1,95,12*0.6,3,3988014,'2022-05-01 10:00:00','1');
insert into product_tab values('蛋糕',47,500,0,'https://qq.com/store/蛋糕.jpg',9.5,30,0.1,36,9.5*0.6,9,3988014,'2022-05-01 10:00:00','1');
insert into product_tab values('玉米片',48,500,0,'https://qq.com/store/玉米片.jpg',12.75,30,0.1,15,12.75*0.6,9,3988015,'2022-05-01 10:00:00','1');
insert into product_tab values('薯条',49,500,0,'https://qq.com/store/薯条.jpg',20,30,0.1,10,20*0.6,9,3988015,'2022-05-01 10:00:00','1');
insert into product_tab values('玉米饼',50,500,0,'https://qq.com/store/玉米饼.jpg',16.25,30,0.1,65,16.25*0.6,9,3988016,'2022-05-01 10:00:00','1');
insert into product_tab values('猪肉干',51,500,0,'https://qq.com/store/猪肉干.jpg',53,30,0.1,20,53*0.6,9,3988016,'2022-05-01 10:00:00','1');
insert into product_tab values('三合一麦片',52,500,0,'https://qq.com/store/三合一麦片.jpg',7,30,0.1,38,7*0.6,7,3988016,'2022-05-01 10:00:00','1');
insert into product_tab values('盐水鸭',53,500,0,'https://qq.com/store/盐水鸭.jpg',32.8,30,0.1,0,32.8*0.6,2,3988016,'2022-05-01 10:00:00','1');
insert into product_tab values('鸡肉',54,500,0,'https://qq.com/store/鸡肉.jpg',7.45,30,0.1,21,7.45*0.6,2,3988016,'2022-05-01 10:00:00','1');
insert into product_tab values('鸭肉',55,500,0,'https://qq.com/store/鸭肉.jpg',24,30,0.1,115,24*0.6,2,3988016,'2022-05-01 10:00:00','1');
insert into product_tab values('白米',56,500,0,'https://qq.com/store/白米.jpg',38,30,0.1,21,38*0.6,7,3988016,'2022-05-01 10:00:00','1');
insert into product_tab values('小米',57,500,0,'https://qq.com/store/小米.jpg',19.5,30,0.1,36,19.5*0.6,7,3988018,'2022-05-01 10:00:00','1');
insert into product_tab values('海参',58,500,0,'https://qq.com/store/海参.jpg',13.25,30,0.1,62,13.25*0.6,3,3988018,'2022-05-01 10:00:00','1');
insert into product_tab values('光明奶酪',59,500,0,'https://qq.com/store/光明奶酪.jpg',55,30,0.1,79,55*0.6,5,3988018,'2022-05-01 10:00:00','1');
insert into product_tab values('花奶酪',60,500,0,'https://qq.com/store/花奶酪.jpg',34,30,0.1,19,34*0.6,5,3988018,'2022-05-01 10:00:00','1');
insert into product_tab values('海鲜酱',61,500,0,'https://qq.com/store/海鲜酱.jpg',28.5,30,0.1,113,28.5*0.6,7,3988019,'2022-05-01 10:00:00','1');
insert into product_tab values('山渣片',62,500,0,'https://qq.com/store/山渣片.jpg',49.3,30,0.1,17,49.3*0.6,9,3988019,'2022-05-01 10:00:00','1');
insert into product_tab values('甜辣酱',63,500,0,'https://qq.com/store/甜辣酱.jpg',43.9,30,0.1,24,43.9*0.6,7,3988019,'2022-05-01 10:00:00','1');
insert into product_tab values('黄豆',64,500,0,'https://qq.com/store/黄豆.jpg',33.25,30,0.1,22,33.25*0.6,7,3988019,'2022-05-01 10:00:00','1');
insert into product_tab values('海苔酱',65,500,0,'https://qq.com/store/海苔酱.jpg',21.05,30,0.1,76,21.05*0.6,7,3988019,'2022-05-01 10:00:00','1');
insert into product_tab values('肉松',66,500,0,'https://qq.com/store/肉松.jpg',17,30,0.1,4,17*0.6,7,3988020,'2022-05-01 10:00:00','1');
insert into product_tab values('矿泉水',67,500,0,'https://qq.com/store/矿泉水.jpg',14,30,0.1,52,14*0.6,8,3988020,'2022-05-01 10:00:00','1');
insert into product_tab values('绿豆糕',68,500,0,'https://qq.com/store/绿豆糕.jpg',12.5,30,0.1,6,12.5*0.6,9,3988020,'2022-05-01 10:00:00','1');
insert into product_tab values('黑奶酪',69,500,0,'https://qq.com/store/黑奶酪.jpg',36,30,0.1,26,36*0.6,5,3988020,'2022-05-01 10:00:00','1');
insert into product_tab values('苏打水',70,500,0,'https://qq.com/store/苏打水.jpg',15,30,0.1,15,15*0.6,8,3988020,'2022-05-01 10:00:00','1');
insert into product_tab values('意大利奶酪',71,500,0,'https://qq.com/store/意大利奶酪.jpg',21.5,30,0.1,26,21.5*0.6,5,3988020,'2022-05-01 10:00:00','1');
insert into product_tab values('酸奶酪',72,500,0,'https://qq.com/store/酸奶酪.jpg',34.8,30,0.1,14,34.8*0.6,5,3988020,'2022-05-01 10:00:00','1');
insert into product_tab values('海哲皮',73,500,0,'https://qq.com/store/海哲皮.jpg',15,30,0.1,101,15*0.6,3,3988020,'2022-05-01 10:00:00','1');
insert into product_tab values('鸡精',74,500,0,'https://qq.com/store/鸡精.jpg',10,30,0.1,4,10*0.6,7,3988007,'2022-05-01 10:00:00','1');
insert into product_tab values('浓缩咖啡',75,500,0,'https://qq.com/store/浓缩咖啡.jpg',7.75,30,0.1,125,7.75*0.6,8,3988007,'2022-05-01 10:00:00','1');
insert into product_tab values('柠檬汁',76,500,0,'https://qq.com/store/柠檬汁.jpg',18,30,0.1,57,18*0.6,8,3988007,'2022-05-01 10:00:00','1');


-- ----------------------------
-- Records of customer_tab
-- ----------------------------    
 insert into customer_tab values ("konojojoda","1234230024003700","qazwsx100",100000,35,"海鲜——鱼");
 insert into customer_tab values ("扎心摸鱼","1234230024003701","666nihao666",100001,5,"零食");
 insert into customer_tab values ("海绵","1234230024003702","qazwsx102",100002,0,"方便面");
 insert into customer_tab values ("好想吃拉面","1234230024003703","99988777",100003,8,"烤肉");
 insert into customer_tab values ("QW23467","1234230024003704","123123123",100004,5,"包子");
 insert into customer_tab values ("rosemarieee","1234230024003705","987okmijn",100005,12,"半成品");
 insert into customer_tab values ("mikasasa","1234230024003706","4629uwdugs",100006,16,"红酒");
 insert into customer_tab values ("名侦探洗衣机","1234230024003707","9848yefyu",100007,17,"奶制品");
 insert into customer_tab values ("退堂鼓艺术家","1234230024003708","ayusdgyu7",100008,20,"奶制品——酸奶");
 insert into customer_tab values ("咸鱼","1234230024003709","fd8vye87w",100009,45,"无糖食品");
 insert into customer_tab values ("不想起名了","1234230024003710","3279rtgygy",100010,168,"半成品");
 insert into customer_tab values ("WEwe5473","1234230024003711","89y8whydf",100011,30,"海鲜——虾");
 insert into customer_tab values ("OT_982746","1234230024003712","27tegf6ytd",100012,3,"海鲜");
 insert into customer_tab values ("小排骨","1234230024003713","90wu8uuddu",100013,375,"蔬菜");
 insert into customer_tab values ("做点白日梦","1234230024003714","q08uf8chufa",100014,69,"蔬菜——卷心菜，上海青");
 insert into customer_tab values ("用户1002","1234230024003715","83duhcusisah",100015,75,"海鲜");
 insert into customer_tab values ("杰哥","1234230024003716","03u8efuhudh",100016,45,"半成品");
 insert into customer_tab values ("Zicky_","1234230024003717","syagvysg67d",100017,65,"海鲜-鱼");
 insert into customer_tab values ("Pepiso","1234230024003718","39hfcubhvgf",100018,45,"饮料");
 insert into customer_tab values ("3Q了","1234230024003719","wr7yf7udhbhf",100019,35,"零食");
 
-- ----------------------------
-- Records of customer_ext_tab
-- ----------------------------    
 insert into customer_ext_tab values(1,100000,"昵称1","乔家大院","17397760532",2.5,"1");
 insert into customer_ext_tab values(2,100000,"昵称2","乔家大院2号","17397760532",2.5,"0");
 insert into customer_ext_tab values(3,100000,"昵称3","开罗别墅","17397760532",2.5,"0");
 insert into customer_ext_tab values(4,100001,"昵称4","魔仙堡公寓","13577689527",2.7,"1");
 insert into customer_ext_tab values(5,100002,"昵称1","深海大菠萝新村","13798420778",2.8,"1");
 insert into customer_ext_tab values(6,100003,"昵称1","叮咚买菜路3号","15994852378",2.9,"1");
 insert into customer_ext_tab values(7,100004,"昵称1","美团买菜路9号","13628987008",1.5,"1");
 insert into customer_ext_tab values(8,100005,"昵称1","奥乐齐商城路11弄","13949723878",3.5,"1");
 insert into customer_ext_tab values(9,100005,"昵称2","OLE商城路2弄","13949723878",3.5,"1");
 insert into customer_ext_tab values(10,100006,"昵称1","盒马路1号","15809283423",4.5,"1");
 insert into customer_ext_tab values(11,100007,"昵称1","淘宝路6号","17783287438",5.5,"1");
 insert into customer_ext_tab values(12,100008,"昵称1","肯德基新村","13009834997",6.5,"1");
 insert into customer_ext_tab values(13,100008,"昵称2","汉堡王新村","13009834997",6.5,"0");
 insert into customer_ext_tab values(14,100009,"昵称1","麦当劳园","12837428932",7.5,"1");
 insert into customer_ext_tab values(15,100010,"昵称1","必胜客大厦","14728647632",8.5,"1");
 insert into customer_ext_tab values(16,100011,"昵称1","达美乐商城","15832483782",10.5,"1");
 insert into customer_ext_tab values(17,100013,"昵称1","上海财经大学国定路","17301972811",12.5,"1");
 insert into customer_ext_tab values(18,100014,"昵称1","上海财经大学武川路","17334907926",12.5,"1");
 insert into customer_ext_tab values(19,100015,"昵称1","五角场合生汇","13617341283",2.5,"1");
 insert into customer_ext_tab values(20,100016,"昵称1","陆家嘴中心","17301932742",1.2,"1");
 insert into customer_ext_tab values(21,100017,"昵称1","外滩花园","15789324798",1.6,"1");
 insert into customer_ext_tab values(22,100018,"昵称1","小杨生煎公寓","15798342731",22.5,"1");
 insert into customer_ext_tab values(23,100019,"昵称1","赛百味大楼","17310984376",3.5,"1");
 
-- ----------------------------
-- Records of cart_tab
-- ----------------------------
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (1, 2, 0.05,1,1,100000,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (2, 1, 0.05,2,1,100000,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (3, 1, 0.05,3,1,100000,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (4, 1, 0.05,4,1,100000,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (5, 2, 0.05,5,1,100000,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (6, 3, 0.05,6,1,100000,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (7, 4, 0.05,7,NULL,100000,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (8, 5, 0.05,8,NULL,100000,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (9, 1, 0.00,5,2,100001,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (10, 2, 0.00,11,2,100001,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (11, 1, 0.00,12,2,100001,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (12, 5, 0.10,20,3,100005,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (13, 1, 0.00,21,3,100005,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (14, 1, 0.00,25,3,100005,'1');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (15, 1, 0.00,11,NULL,100007,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (16, 2, 0.00,15,NULL,100007,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (17, 3, 0.00,16,NULL,100007,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (18, 2, 0.00,17,NULL,100007,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (19, 1, 0.00,30,NULL,100007,'0');
INSERT INTO cart_tab(car_id,total_number,discount,pro_id,ord_id,cus_id,car_stat) VALUES (20, 3, 0.00,51,4,100009,'1');


-- ----------------------------
-- Records of order_tab
-- ----------------------------
INSERT INTO order_tab(ord_id,express_num,ord_time,ord_price,discount,deliver_fee,ord_quan,points,ord_ext_id,st_id,ord_stat) 
			VALUES (1, '202205080000001', '2022-05-08 17:30:31', 194.46, 0.10, 5,10, '8.00', 1, 3350001, '6');
INSERT INTO order_tab(ord_id,express_num,ord_time,ord_price,discount,deliver_fee,ord_quan,points,ord_ext_id,st_id,ord_stat) 
			VALUES (2, '202205100000001', '2022-05-10 12:30:48', 101.35, 0.00, 10,4, '6.00', 4, 3350002, '6');
INSERT INTO order_tab(ord_id,express_num,ord_time,ord_price,discount,deliver_fee,ord_quan,points,ord_ext_id,st_id,ord_stat) 
			VALUES (3, '202205100000002', '2022-05-10 14:33:12', 388.50, 0.00, 8,7, '12.00', 9, 3350003, '2');
INSERT INTO order_tab(ord_id,express_num,ord_time,ord_price,discount,deliver_fee,ord_quan,points,ord_ext_id,st_id,ord_stat) 
			VALUES (4, '202205100000003', '2022-05-10 18:13:22', 159.00, 0.00, 12,3, '7.00', 14, 3350004, '2');

-- ----------------------------
-- Records of pay_tab
-- ----------------------------
INSERT INTO pay_tab(pay_id,pay_date,pay_type,pay_stat,pay_amount,pay_confirm,ord_id,pay_code) 	
	VALUES(1,'2022-05-08 17:28:31','1','1',199.46,'0',1,'WX1234567890');
INSERT INTO pay_tab(pay_id,pay_date,pay_type,pay_stat,pay_amount,pay_confirm,ord_id,pay_code) 
	VALUES(2,'2022-05-10 12:29:48','1','1',111.35,'0',2,'WX1234567891');
INSERT INTO pay_tab(pay_id,pay_date,pay_type,pay_stat,pay_amount,pay_confirm,ord_id,pay_code) 
	VALUES(3,'2022-05-10 14:30:12','1','1',396.50,'0',3,'ZFB1234567892');
INSERT INTO pay_tab(pay_id,pay_date,pay_type,pay_stat,pay_amount,pay_confirm,ord_id,pay_code) 
	VALUES(4,'2022-05-10 18:11:22','1','1',171.00,'0',4,'ZFB1234567893');
-- ----------------------------
-- Records of comment_tab
-- ----------------------------   
insert into comment_tab values ("东西挺新鲜的",1,'2022-05-08 19:30:31',100001,1);
insert into comment_tab values ("物流很快，谢谢",1,'2022-05-10 13:30:48',100002,2);
 
-- ----------------------------
-- Records of administrator_tab
-- ----------------------------   
insert into administrator_tab(adm_name,adm_code,adm_level,st_id) values('ADM111','Zz11111','1',2364001);
insert into administrator_tab(adm_name,adm_code,adm_level,st_id) values('ADM112','Yy11111','2',2364002);
insert into administrator_tab(adm_name,adm_code,adm_level,st_id) values('ADM113','Ww11111','2',2364003);

-- ----------------------------
-- Records of notice_tab
-- ----------------------------  
insert into notice_tab values (1,'重要通知','https://qqcloud.com/notice1.html','2021-12-28 09:00:01','2','2022-01-01 00:00:01','2022-01-03 23:59:59','ADM111');
insert into notice_tab values (2,'五一活动通告','https://qqcloud.com/notice2.html','2022-03-01 10:15:35','0','2022-04-20 00:00:01','2022-05-05 23:59:59','ADM111');
insert into notice_tab values (3,'关于近期配送时间的说明','https://qqcloud.com/notice3.html','2022-03-10 15:02:25','2','2022-03-11 00:00:01','2022-03-15 23:59:59','ADM112');
insert into notice_tab values (4,'积分双倍活动','https://qqcloud.com/notice4.html','2022-04-02 09:02:21','0','2022-10-31 00:00:01','2022-05-03 23:59:59','ADM113');
insert into notice_tab values (6,'系统运维通告','https://qqcloud.com/notice5.html','2022-05-10 17:08:25','1','2022-05-11 22:00:00','2022-05-11 23:59:59','ADM113');

-----------------------------
-- Records of activities_tab
-- ----------------------------  
insert into activities_tab(act_id,act_date,act_type,act_limit,act_discount,act_start,act_end,act_stat) 
	values(1,'2021-09-03 12:01:01','0',300,10.00,'2022-01-01 00:00:01','2022-12-31 23:59:59','1');
insert into activities_tab(act_id,act_date,act_type,act_limit,act_discount,act_start,act_end,act_stat) 
	values(2,'2021-09-03 12:01:01','1',500,0.10,'2022-06-01 00:00:01','2022-06-18 23:59:59','1');
insert into activities_tab(act_id,act_date,act_type,act_limit,act_discount,act_start,act_end,act_stat) 
	values(3,'2021-09-03 12:01:01','2',0,2.00,'2022-10-01 00:00:01','2022-10-31 23:59:59','1');
    
  -- ----------------------------
-- Records of product_store_tab
-- ---------------------------- 
insert into product_store_tab values(1,76,15,100,8,3988007,'2022-05-01 11:00:00');
insert into product_store_tab values(2,76,16,80,8,3988007,'2022-05-02 14:30:00');
insert into product_store_tab values(3,76,13,150,8,3988007,'2022-05-03 09:28:10');

insert into product_store_tab values(4,3,6,50,7,3988001,'2022-05-01 13:01:00');
insert into product_store_tab values(5,3,5,70,7,3988001,'2022-05-02 18:30:15');  

SET FOREIGN_KEY_CHECKS = 1;
#创建对应数据库用户名、角色和权限
CREATE USER IF NOT EXISTS 'db_customer'@'%' IDENTIFIED WITH mysql_native_password by '111111' ; #新建客户操作的对应数据库用户名
CREATE USER IF NOT EXISTS 'db_staff'@'%' IDENTIFIED WITH mysql_native_password by '222222' ;  #新建普通内勤员工操作的对应数据库用户名
CREATE USER IF NOT EXISTS 'db_admin'@'%' IDENTIFIED WITH mysql_native_password by '333333' ;  #新建管理员操作的对应数据库用户名

create role IF NOT EXISTS 'customer_role', 'staff_role','admin_role'; #新建客户、内勤、管理三种角色对应三个不同等级权限
grant all on grocery.* to 'admin_role'; #赋予管理员角色所有权限
grant select,delete,update on grocery.comment_tab to 'customer_role';
grant select,delete,update on grocery.customer_tab to 'customer_role';
grant select,delete,update on grocery.customer_ext_tab to 'customer_role';
grant select,delete,update on grocery.order_tab to 'customer_role';
grant select,delete,update on grocery.cart_tab to 'customer_role';
grant select,delete,update on grocery.pay_tab to 'customer_role';

grant select on grocery.notice_tab to 'customer_role';
grant select on grocery.activities_tab to 'customer_role';
grant select on grocery.type_tab to 'customer_role';
grant select on grocery.type_tab to 'customer_role';
grant select on grocery.product_tab to 'customer_role';

grant select,delete,update on grocery.product_tab to 'staff_role';
grant select,delete,update on grocery.type_tab to 'staff_role';
grant select on grocery.order_tab to 'staff_role';
grant select on grocery.notice_tab to 'staff_role';
grant select on grocery.activities_tab to 'staff_role';
grant update(ord_stat) on grocery.order_tab to 'staff_role';

grant 'customer_role' to 'db_customer'@'%';
grant 'staff_role' to 'db_staff'@'%';
grant 'admin_role' to 'db_admin'@'%';

show grants for 'db_customer'@'%';
show grants for 'db_staff'@'%';
show grants for 'db_admin'@'%';
