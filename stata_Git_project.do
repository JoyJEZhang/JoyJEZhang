*打开原始数据Excel,数据来源CSmar
cd ///
"C:\Users\Joy\Desktop\0618\" 
import excel "C:\Users\Joy\Desktop\0618\TMT_FIGUREINFO.xlsx" ,first clear
save character.dta, replace

g Year = substr(Reptdt,1,4)
destring Year, force replace
keep if regexm(Reptdt,"12-31")
drop Reptdt
order Stkcd Year

*
la var TotalSalary 高管薪酬
duplicates drop TotalSalary Year, force
keep if TotalSalary > 0
drop if TotalSalary == .

*
g g = Gender != "女"
tostring g, replace
replace Gender = g
drop g
destring Gen, force replace
la var Gen "性别（男=1，女=0）"
 
*
keep if regexm(IsMTMT,"1") /*高管团队成员*/
save 高管.dta, replace
*
use 高管.dta
keep if regexm(OveseaBack,"1") | regexm(OveseaBack,"2") /*海外任职or留学*/
 save 高管海外背景.dta, replace
*
use 高管.dta
keep if Gender == 0 /*女性*/
 save 女性高管文件.dta, replace



*1统计高管海外背景与薪酬的关系
*2回归女性高管与企业发展情况的关系
***4管理团队的dea投入研发产出

*1.合并三大报表与数据
 *导入原始数据
   
  *01_资产负债表
  import excel FS_Combas.xlsx, first clear  
  save FS_Combas.dta, replace 
  
  *02_利润表_
  import excel FS_Comins.xlsx, first clear  
  save FS_Comins.dta, replace 
  
  *03_现金流量表(直接法)
  import excel FS_Comscfd.xlsx, first clear  
  save FS_Comscfd.dta, replace 
  
  
******************************************************************************** 
 *数据处理
  use FS_Combas.dta, clear
  sort Stkcd Accper Typrep
  duplicates drop Stkcd Accper Typrep, force
  
  merge 1:1 Stkcd Accper Typrep using FS_Comins.dta
  drop if _merge == 2
  drop _merge  

  merge 1:1 Stkcd Accper Typrep using FS_Comscfd.dta
  drop if _merge == 2
  drop _merge  
    
  save Accounting_2020_2023.dta, replace
 help merge
********************************************************************************   
  *合并数据Accounting_plus
  use Accounting_2020_2023.dta, clear  

    gen ID    = real(Stkcd)
    gen Year  = substr(Accper,1,4)
    gen Month = substr(Accper,6,2)
    destring Year Month, replace
    keep if Typrep == "A"
    keep if Month  == 12
    duplicates drop ID Year, force
	
  label var A001000000 AT 
  label var A002000000 LT 
  label var A003000000 BE
  label var A001220000 Goodwill
  /*label var A001100000 ACT 	       
  label var A001200000 ALT
  label var A001111000 AP 
  label var A001212000 PPE_NT
  label var A002100000 LCT         
  label var A002200000 LLT*/
  label var B001100000 Sale        
  label var B001200000 Cost      
  label var B001101000 Sale_opr    
  label var B001201000 Cost_opr
  label var B001209000 XSale       
  label var B001210000 XMnge 
  label var B001211000 XFin
  label var B001216000 XRD
  label var B001300000 Income_opr  
  label var B001000000 Income_total 
  label var B002000000 NI
  label var B003000000 EPS_basic   
  label var B004000000 EPS_dilut
  label var C001000000 CFO         
  label var C002000000 CFI 
  label var C003000000 CFF
  
  rename A001000000 AT 
  rename A002000000 LT 
  rename A003000000 BE
  rename A001220000 Goodwill
  /*rename A001100000 ACT 	       
  rename A001200000 ALT
  rename A001111000 AP 
  rename A001212000 PPE_NT
  rename A002100000 LCT         
  rename A002200000 LLT*/
  rename B001100000 Sale        
  rename B001200000 Cost      
  rename B001101000 Sale_opr    
 rename B001201000 Cost_opr
  rename B001209000 XSale       
  rename B001210000 XMnge 
  rename B001211000 XFin
  rename B001216000 XRD
  rename B001300000 Income_opr  
  rename B001000000 Income_total   
  rename B002000000 NI
 rename B003000000 EPS_basic   
 rename B004000000 EPS_dilut
  rename C001000000 CFO         
  rename C002000000 CFI 
  rename C003000000 CFF
    	
  
  keep  ID   Year   Stkcd   Accper Typrep AT Goodwill   LT	 BE	   ///
       /*ACT	 ALT	AP	      PPE_NT	LCT	 LLT  */ ///
       Sale	 Cost   Sale_opr  Cost_opr	          ///
       XSale XMnge	XFin	  XRD	    Income_opr ///
       /*Income_total*/	NI	      EPS_basic EPS_dilut  ///
       CFO	 CFI	CFF 
	   
  order ID   Year   Stkcd   Accper Typrep AT	Goodwill    LT	 BE	   ///
       /*ACT	 ALT	AP	      PPE_NT	LCT	 LLT  */ ///
       Sale	 Cost   Sale_opr  Cost_opr	          ///
       XSale XMnge	XFin	  XRD	    Income_opr ///
       /*Income_total*/	NI	      EPS_basic EPS_dilut  ///
	   
  save CSMAR_ACC_Plus_2020_2023.dta, replace 
   
*加入行业
import excel STK_LISTEDCOINFOANL.xlsx , first clear
save STK_LISTEDCOINFOANL.dta,replace
use STK_LISTEDCOINFOANL.dta,clear
 gen ID    = real(Symbol)
  gen Year  = substr(EndDate,1,4)
  gen Month = substr(EndDate,6,2)
  destring Year Month, replace  
  keep if Month == 12  
  duplicates drop ID Year, force  
  
  *行业,地区
  keep ID Year IndustryCode IndustryName PROVINCE
  gen IndustryD = substr(IndustryCode,1,1)
  replace IndustryD = substr(IndustryCode,1,2) if IndustryD == "C"
  gen ProvinceD = substr(PROVINCE,1,6)
  
  keep  ID Year IndustryD IndustryName ProvinceD
  order ID Year IndustryD IndustryName ProvinceD
  label var IndustryD "行业"
  label var IndustryName "行业名称"
  label var ProvinceD "省份"
  
  save 上市公司基本信息年度表_2000_2022.dta, replace


  use CSMAR_ACC_Plus_2020_2023.dta, clear
  sort ID Year
  duplicates drop ID Year, force
  
  merge 1:1 ID Year using 上市公司基本信息年度表_2000_2022.dta
  drop if _merge == 2
  drop _merge  
save indfull.dta, replace




*2回归女性高管比例与企业绩效波动性的关系
*自变量:女性高管占高管团队比例'
*因变量：sdroe sdroa sdeps sdsize1 sdsize2 


*生成女性高管占所处企业高管团队比例

use data_full.dta, clear

  tab Gender, gen(male)
bys Stkcd: egen female = total(male1)
bys Stkcd: egen male = total(male2)
bys Stkcd: gen sex_ratio = female/(male+female)
drop male female male1 male2
  duplicates drop Stkcd Year, force
  keep Stkcd sex_ratio
  save sex_ratio.dta,replace
   
   *从这里运行
   use indfull.dta, clear
  sort Stkcd 
  /*duplicates drop Stkcd Year, force*/
  merge m:1 Stkcd using sex_ratio.dta
  drop if _merge == 2
  drop _merge
  save FULL.dta, replace
/*gen d = 1
collapse (sum) num_stckd = d, by(Stkcd Gender)*/
*****************************************************
* ROA	净利润/平均总资产，其中平均总资产=（本年末总资产+上年末总资产）/2
   xtset ID Year
  gen ROA=NI/((AT+L.AT)/2)
  gen ROE = NI/((BE+L.BE)/2) if BE > 0
  gen LOSS = 0 if NI ~= .
  replace LOSS = 1 if NI < 0 & NI ~= .
  gen LOSS2 = NI < 0 if NI ~= .  
  gen Size = ln(AT)
  gen Size2 = ln(Sale)
  gen LEV = AT/BE
  
  *样本删选与极端值处理
 
  winsor2 ROA ROE Size Size2,replace 
  egen X1 = mean(ROE) 
  egen X2 = mean(ROE) , by(Year)
  gen ROE_dmrk = ROE - X2
    
  egen MacSale = sum(Sale), by(Year)
  gen  Marketshare = Sale/MacSale
  
  
 xtset ID Year
 gen EPSGrowth = (EPS_basic - l1.EPS_basic)/l1.EPS_basic  if l1.EPS_basic > 0 & EPS_basic > 0
 
 gen F1_EPSGrowth = f1.EPSGrowth
 
 gen ROAL = NI/l1.AT if l1.AT > 0
 
 gen SaleGrowth = Sale/l1.Sale - 1
 
 gen CFO_AT = CFO/l1.AT if l1.AT>0

 gen oprProfit_AT = Income_opr/l1.AT if l1.AT>0
egen sdroe = sd(ROE)
egen sdroa = sd(ROA)
egen sdeps = sd(EPS_basic)
egen sdsize1 =sd(Size)
egen sdsize2 = sd(Size2)


keep sdroe sdroa sdeps sdsize1 sdsize2 sex_ratio ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT IndustryD


keep if sdroe + sdroa + sdeps + sdsize1 + sdsize2 + sex_ratio + ROE_dmrk  + Marketshare + F1_EPSGrowth + ROAL + SaleGrowth  + ID + CFO_AT + oprProfit_AT ~= .

winsor2 sdroe sdroa sdeps sdsize1 sdsize2  sex_ratio ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT, replace

save FULL2.dta, replace
******************************************************************************
logout, save(table001) excel replace: ///
tabstat /*sdroe sdroa sdeps sdsize1 sdsize2*/  sex_ratio ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT, stats(n mean sd min p10 p25 p50 p75 p90 max) c(s) f(%10.2f)
**********************************************************************************
logout, save(table2) excel replace: /// 
 pwcorr_a /*sdroe sdroa sdeps sdsize1 sdsize2*/  sex_ratio ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT, star1(0.01) star5(0.05) star10(0.1)
logout, save(table2) excel replace: /// 
 pwcorr_a sdroe sdroa sdeps sdsize1 sdsize2 sex_ratio
************************************************************************************************
reg  ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT

est store H01

*
	use FULL2.dta,clear
	
  *女性高管比例与ROE
  *女性高管比例与oprProfit_AT
  quiet reg ROE  sex_ratio
   est store H01
  quiet reg oprProfit_AT sex_ratio
   est store H02
  outreg2 [H0*] using "Reg03", excel replace tstat  bdec(4) tdec(3) rdec(4) adjr2 e(F) nonote  
*

outreg2 [H01] using "Reg01", excel replace tstat bdec(4) tdec(3) rdec(4) adjr2 e(F) nonote

outreg2 [H01] using "Reg01", excel replace pvalue bdec(4) tdec(3) rdec(4) adjr2 e(F) nonote

reg sex_ratio ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT

*稳健
reg  ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT
est store H01
reg  ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT
est store H02
outreg2 [H01] using "Reg01", excel replace tstat bdec(4) tdec(3) rdec(4) adjr2 e(F) nonote

 reg ROE_dmrk  Marketshare F1_EPSGrowth ROAL SaleGrowth ID Year CFO_AT oprProfit_AT, r cl(ID)  
 est store H01
 outreg2 [H0*] using "Reg01", excel replace tstat  bdec(4) tdec(3) rdec(4) adjr2 e(F) nonote 
 *比较有女性高管成长性是不是更好
 *有
 quiet xi:reg F1_EPSGrowth SaleGrowth CFO_AT oprProfit_AT  i.Year i.IndustryD if sex_ratio == 0 , r cl(ID)
   est store H01
 *没有
  quiet xi:reg F1_EPSGrowth SaleGrowth CFO_AT oprProfit_AT i.Year i.IndustryD if sex_ratio != 0, r cl(ID)
   est store H02
  outreg2 [H0*] using "Reg03", excel replace tstat  bdec(4) tdec(3) rdec(4) adjr2 e(F) nonote  
  
  
  
  
    
  ***********************************************************************************
*Dea投入产出分析尝试

*加入行业
import excel STK_LISTEDCOINFOANL.xlsx , first clear
save STK_LISTEDCOINFOANL.dta,replace
use STK_LISTEDCOINFOANL.dta,clear
 gen ID    = real(Symbol)
  gen Year  = substr(EndDate,1,4)
  gen Month = substr(EndDate,6,2)
  destring Year Month, replace  
  keep if Month == 12  
  duplicates drop ID Year, force  
  
  *行业,地区
  keep ID Year IndustryCode IndustryName PROVINCE
  gen IndustryD = substr(IndustryCode,1,1)
  replace IndustryD = substr(IndustryCode,1,2) if IndustryD == "C"
  gen ProvinceD = substr(PROVINCE,1,6)
  
  keep  ID Year IndustryD IndustryName ProvinceD
  order ID Year IndustryD IndustryName ProvinceD
  label var IndustryD "行业"
  label var IndustryName "行业名称"
  label var ProvinceD "省份"
  
  save 上市公司基本信息年度表_2000_2022.dta, replace


  use CSMAR_ACC_Plus_2020_2023.dta, clear
  sort ID Year
  duplicates drop ID Year, force
  
  merge 1:1 ID Year using 上市公司基本信息年度表_2000_2022.dta
  drop if _merge == 2
  drop _merge  
save indfull.dta, replace




*******************************************************************************
ssc install egenmore
ssc install hhi

* 切换到数据所在路径
use indfull.dta, clear
replace Goodwill=0 if Goodwill==.
replace XRD=0 if XRD==.
gen XSM=XSale+XMnge



* 剔除金融行业
drop if IndustryD=="J"

egen Ind=group(IndustryD)
sum Ind

* 剔除缺失值
foreach i in  Goodwill XRD Cost_opr XSM Sale_opr {
   drop if `i'==.
}

* 唯一识别代码(DEA软件需要用到)
gen dmu=Stkcd+string(Year)

winsor2 Goodwill XRD Cost_opr XSM Sale_opr, cuts(1 99) replace by(Year)

* 整理出DEA SOLVER 15 计算需要的excel格式
order dmu Goodwill XRD Cost_opr XSM Sale_opr
foreach i in  Goodwill XRD Cost_opr XSM Sale_opr {
  label var `i' "(I)`i'"
}
label var Sale_opr "(O)营业收入"
save dataDEA.dta, replace

* 分行业导出数据
forv i=1/21 {
	use dataDEA.dta, clear
	label var dmu "dmu"
	keep if Ind==`i'
	keep dmu Goodwill XRD Cost_opr XSM Sale_opr
	export excel 行业`i'.xls, firstrow("varlabels") replace sheet("DAT") nolabel
}

 
* 商誉、研发支出、营业成本、销售与管理费用作为DEA分析中的投入变量， 
* 把营业收入作为唯一的产出变量，通过数据包络分析计算得出企业效率值。


* 使用DEA Solver分行业计算效率值 模型使用CCR-I
* 结果文件命名为 行业1结果.xlsx 行业2结果.xlsx.... 

* 效率结果导入
/*
forv i=1/21 {
	import excel 行业`i'结果.xls,  clear sheet("Score") cellrange(B4) firstrow
	keep DMU Score
	drop if DMU=="" |  DMU=="Mean" | DMU=="Max" | DMU=="Min" | DMU=="St Dev"
	sum 
	save 行业`i'r.dta, replace
}
*/


forv i=1/21 {
	import excel 行业`i'结果.xls,  clear sheet("Score") cellrange(B4) firstrow
	keep DMU Score
	
	sum 
	save 行业`i'r.dta, replace
}

* 合并结果数据
clear
forv i=1/21 {
	append using 行业`i'r.dta
}
tostring DMU,gen(DUMstr)
gen Stkcd=substr(DUMstr, 1, length(DUMstr)-4)
gen Year=real(substr(DUMstr, length(DUMstr)-3, 4))
rename Score Firm_Efficiency
save DEA结果.dta, replace

/*
clear
forv i=1/21 {
	append using 行业`i'r.dta
}
gen Stkcd=real(substr(DMU, 1, length(DMU)-4))
gen Year=real(substr(DMU, length(DMU)-3, 4))
rename Score Firm_Efficiency
save DEA结果.dta, replace
*/


* Tobit模型中控制的企业层面因素包括企业规模、市场份额、自由现金流
use indfull.dta, clear
merge 1:1 Stkcd Year using DEA结果.dta, nogen keep(1 3)
* 企业规模  Ln(Total Assets)
gen LnTotalAssets=ln(AT)

* 市场份额 Market Share
bys IndustryD Year: egen 行业营业收入总和=sum(Sale_opr)
gen MarketShare =Sale_opr/行业营业收入总和

* 自由现金流 Positive Free Cash Flow
gen PositiveFreeCashFlow=(CFF>0) if CFF!=.



* 剔除缺失值
foreach i in Firm_Efficiency LnTotalAssets MarketShare PositiveFreeCashFlow {
   drop if `i'==.
}

* 缩尾处理
* ssc install winsor2
winsor2  LnTotalAssets MarketShare PositiveFreeCashFlow , cuts(1 99) replace by(Year)


* Tobit回归
tobit Firm_Efficiency LnTotalAssets MarketShare PositiveFreeCashFlow i.Year, ll(0) ul(1)


predict 预测值
gen MA_Score=Firm_Efficiency-预测值

* 将回归残差从小到大分成四组
bys Year: egen MA4=xtile(MA_Score), n(4)

keep  Stkcd Year MA_Score MA4
sort Stkcd Year

*  描述性统计
tabstat  MA_Score MA4, c(s) s(N mean sd min p50 max) format(%10.3f)


order Stkcd
save 企业管理评价.dta,  replace
export excel 企业管理评价.xlsx, firstrow(var) replace

  
  
  
  
  


