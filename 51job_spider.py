# -*- coding: UTF-8 -*-
import random
import asyncio
import time
import aiohttp
import pandas as pd
import os
from datetime import datetime

#51JOB有防爬措施，因此需要适当延时抓取速度
#51JOB的链接地址分析
#         地区表, 待定，  待定，行业（0-24）,,+,2,页码.html
#  /list/:jobarea,:district,:funtype,:industrytype,:issuedate,:providesalary,:keyword,:keywordtype,:curr_page.html
url_51job = "https://search.51job.com/list/010000,000000,0000,{area},9,99,+,2,1.html"
DEFAULT_HEADER = {
    'User-Agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36",
    'Accept': 'application/json',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
}

JOB_AREA = {
    # "全国": '000000',
    # "北京": '010000',
    '上海': '020000',
    # "广东省": "030000",
    # "江苏省": "070000",
    # "浙江省": "080000",
    # "四川省": "090000",
    # "海南省": "100000",
    # "福建省": "110000",
    # "山东省": "120000",
    # "江西省": "130000",
    # "广西": "140000",
    # "安徽省": "150000",
    # "河北省": "160000",
    # "河南省": "170000",
    # "湖北省": "180000",
    # "湖南省": "190000",
    # "陕西省": "200000",
    # "山西省": "210000",
    # "黑龙江省": "220000",
    # "辽宁省": "230000",
    # "吉林省": "240000",
    # "云南省": "250000",
    # "贵州省": "260000",
    # "甘肃省": "270000",
    # "内蒙古": "280000",
    # "宁夏": "290000",
    # "西藏": "300000",
    # "新疆": "310000",
    # "青海省": "320000",
    # "香港": "330000",
    # "澳门": "340000",
    # "台湾": "350000",
    # "国外": "360000"
}
INDUSTRY_TYPE = {
    "餐饮业": "11",
    "广告": "12",
    "文字媒体/出版": "13",
    "机械/设备/重工": "14",
    "印刷/包装/造纸": "15",
    "采掘业/冶炼": "16",
    "娱乐/休闲/体育": "17",
    "法律": "18",
    "石油/化工/矿产/地质": "19",
    "环保": "20",
    "交通/运输/物流": "21",
    "批发/零售": "22",
    "教育/培训/院校": "23",
    "学术/科研": "24",
    "房地产": "26",
    "生活服务": "27",
    "政府/公共事业": "28",
    "农/林/牧/渔": "29",
    "通信/电信/网络设备": "31",
    "互联网/电子商务": "32",
    "汽车": "33",
    "中介服务": "34",
    "仪器仪表/工业自动化": "35",
    "电气/电力/水利": "36",
    "计算机硬件": "37",
    "计算机服务(系统、数据服务、维修)": "38",
    "通信/电信运营、增值服务": "39",
    "网络游戏": "40",
    "会计/审计": "41",
    "银行": "42",
    "保险": "43",
    "家具/家电/玩具/礼品": "44",
    "办公用品及设备": "45",
    "医疗/护理/卫生": "46",
    "医疗设备/器械": "47",
    "公关/市场推广/会展": "48",
    "影视/媒体/艺术/文化传播": "49",
    "家居/室内设计/装潢": "50",
    "物业管理/商业中心": "51",
    "检测，认证": "52",
    "酒店/旅游": "53",
    "美容/保健": "54",
    "航天/航空": "55",
    "原材料和加工": "56",
    "非营利组织": "57",
    "多元化业务集团公司": "58",
    "外包服务": "59",
    "奢侈品/收藏品/工艺品/珠宝": "60",
    "新能源": "61",
    "信托/担保/拍卖/典当": "62",
    "租赁服务": "63",
    "汽车零配件": "65",
    "计算机软件": "01",
    "电子技术/半导体/集成电路": "02",
    "金融/投资/证券": "03",
    "贸易/进出口": "04",
    "快速消费品(食品、饮料、化妆品)": "05",
    "服装/纺织/皮革": "06",
    "制药/生物工程": "08",
    "建筑/建材/工程": "09",
    "专业服务(咨询、人力资源、财会)": "07"
}

DEFAULT_PAYLOAD = {
    'lang': 'c',
    'postchannel': '0000',
    'workyear': '99',
    'cotype': '99',
    'degreefrom': '99',
    'jobterm': '99',
    'companysize': '99',
    'ord_field': '0',
    'dibiaoid': '0',
    'line': "",
    'welfare': "",
}

def save_to_excel(dfs, file_name, folder=None):
    """save_to_excel(dfs [,file_name] [,folder=None])
    :param dfs: 结果数据 databases
    :param file_name:  输出文件名
    :param folder: 是否制定特定目录，不指定则当前目录
    :return: None

    """
    print(f'start writing files....')
    folder = folder if folder else os.path.dirname(os.path.abspath(__file__))
    file_location = os.path.join(folder, f"{file_name}.xlsx")
    writer = pd.ExcelWriter(file_location)
    df_name = 0
    if isinstance(dfs, list):
        for df in dfs:
            if df is not None:
                df.to_excel(excel_writer=writer, sheet_name=f'sheet_{df_name}', index=False)
                df_name += 1
    elif isinstance(dfs, pd.DataFrame):
        dfs.to_excel(excel_writer=writer, sheet_name=f'sheet_{df_name}', index=False)
    else:
        raise Exception("输入数据格式不正确")
    writer.save()
    print(f'file successfully generated  at {datetime.now()} ,location:  {file_location}')
    writer.close()

async def get_51job_page_cnt(url):  
    try:
        async with aiohttp.ClientSession(headers=DEFAULT_HEADER, connector=aiohttp.TCPConnector(limit=40)) as cs:
            ts = random.randint(0, 10)
            print(f'[防爆爬取]随机延迟{ts}秒请求...')
            await asyncio.sleep(ts)
            async with cs.post(url, params=DEFAULT_PAYLOAD) as resp:
                result = await resp.json(content_type=None)
                print(f"current industry: {result['searched_condition']}")
                key = result['search_condition']['industrytype']
                value = int(result['total_page'])
                return [key, value]
    except Exception as e:
        print(e)


async def get_51job_per_page(url):
    try:
        async with aiohttp.ClientSession(headers=DEFAULT_HEADER) as cs:
            ts = random.randint(0, 3)
            print(f'[防爆爬取]#详情#随机延迟{ts}秒请求...')
            await asyncio.sleep(ts)
            async with cs.get(url, params=DEFAULT_PAYLOAD) as resp:
                result = await resp.json(content_type=None)
                print(f"current industry:{result['searched_condition']} and page {result['curr_page']}")
                return result['engine_jds']
    except Exception as e:
        print(e)


if __name__ == '__main__':
    result = []
    job51_data_url = "https://search.51job.com/list/{},000000,0000,{},9,99,+,2,{}.html"
    # loop = asyncio.get_event_loop()
    # loop.run_until_complete(get_51job_page_cnt('https://search.51job.com/list/010000,000000,0000,51,9,99,+,2,3.html'))
    file_slice = 1
    job_result = []
    for job_area, job_area_code in JOB_AREA.items():
        indu_task_list = []
        # 爬取当前地区的行业职位数量
        loop = asyncio.get_event_loop()
        for industry_code in INDUSTRY_TYPE.values():
            indu_task_list.append(get_51job_page_cnt(job51_data_url.format(job_area_code, industry_code, 1)))
        indu_task_result = loop.run_until_complete(asyncio.wait(indu_task_list))
        if len(indu_task_result) == 1:
            indu_result = [indu_task_result[0].result]
        else:
            indu_result = [task.result() for task in indu_task_result[0]]
        # 爬取当前地区各个行业的职位信息
        for indu in indu_result:
            # indu[1] 当前行业职位总页码, 默认爬取前两页  数据量太大，根据智能排序后，抓取重点数据
            indu[1] = 2 if indu[1] > 2 else indu[1]
            job_task_list = [get_51job_per_page(job51_data_url.format(job_area_code, indu[0], page)) for page in
                             range(1, indu[1] + 1)]
            job_task_result = loop.run_until_complete(asyncio.wait(job_task_list))
            for job_info in [task.result() for task in job_task_result[0]]:
                job_result += job_info
            #定期写入数据，防止运行时间过长或者数据量大造成程序异常，数据丢失
            if len(job_result) > 10000:
                df_jobs = pd.DataFrame(job_result)
                save_to_excel(df_jobs, f"{job_area}职位数据{file_slice}")
                file_slice += 1
                job_result = []
                ts = random.randint(10, 50)
                print(f'[防爆爬取]程序休息{ts}秒后继续...')
                time.sleep(ts)
    if len(job_result) > 0:
        df_jobs = pd.DataFrame(job_result)
        save_to_excel(df_jobs, f"{job_area}职位数据{file_slice}")
        file_slice += 1
        job_result = []
        print(f'[爬虫运行]程序已结束...')