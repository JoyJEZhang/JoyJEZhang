# -*- coding: UTF-8 -*-
import os
from time import sleep
from datetime import datetime
from copy import deepcopy
import random

import requests
from pandas import Series, DataFrame, ExcelWriter


hurun_data_url = 'https://www.hurun.net/zh-CN/Rank/HsRankDetailsList'  #胡润数据网站的对外公共数据接口地址
TEMPLATE_PAYLOAD = {
    #'num': 'IH8GTUI9', --global  #此NUM号为对应数据网页的对应排名
    #'num': 'YUBAO34E',  #百富  #此NUM号为对应数据网页的对应排名
    'num': '1MNBD7MC',  #民营500  #此NUM号为对应数据网页的对应排名
    'search': None,
    'offset': 0,
    'limit': 20
}
DEFAULT_HEADER = {
    'content-type':'application/json',
    'cache-control': 'no-cache',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36',
    'referer': 'https://www.hurun.net/zh-CN/Rank/HsRankDetails?pagetype=ctop500', #民营五百强  #实际的数据网页地址，和NUM要一一对应
    #'referer': 'https://www.hurun.net/zh-CN/Rank/HsRankDetails?pagetype=global',  #全球
    #'referer': 'https://www.hurun.net/zh-CN/Rank/HsRankDetails?pagetype=rich',  #中国百富榜

}


#获取数据总数的定义，用以爬虫数据的简单核对和输出显示用，没有其他的实际具体用途
def get_hurun_total(url, request_data):
    rec_counts = None
    resp = requests.get(url=url, params=request_data, headers=DEFAULT_HEADER)
    if resp.status_code == 200:
        resp_data = resp.json()
    rec_counts = resp_data['total']
    return rec_counts

#获取具体数据，接口返回的是JSON报文，具体解析报文内容即可
def get_hurun_data(url, offset, limit):
    payload = deepcopy(TEMPLATE_PAYLOAD)
    payload['offset'] = offset
    payload['limit'] = limit
    sleep(random.uniform(0.1, 0.5))
    resp = requests.get(url, headers=DEFAULT_HEADER, params=payload)
    print(f"load data:{offset}: page_cnt:{limit}")
    if resp.status_code == 200:
        return resp.json()['rows']
    raise Exception(msg=f"error in spider,resp_code:{resp.status_code}")

#将获取的数据写入XLS
def save_to_excel(dfs, file_name, dir=None):
    dir = dir if dir else os.path.dirname(os.path.abspath(__file__))
    file_location = os.path.join(dir, f"{file_name}.xlsx")
    writer = ExcelWriter(file_location)
    df_name = 0
    for df in dfs:
        if df is not None:
            df.to_excel(excel_writer=writer, sheet_name=f'sheet_{df_name}', index=False)
            df_name += 1
    writer.save()
    print(f'file successfully generated  at {datetime.now()} ,location:  {file_location}')

#程序主体，通过对之前定义方法的引用和简单数据清理来实现数据获取
if __name__ == "__main__":
    rec_per_page = 100
    rec_counts = get_hurun_total(hurun_data_url, TEMPLATE_PAYLOAD)
    result_data = [get_hurun_data(hurun_data_url, cur_data, rec_per_page)
                   for cur_data in range(0, rec_counts, rec_per_page)]
    clean_data = []
    clean_data_person = []
    df_person, df_rank = None, None
    for row in result_data:
        clean_data += row
    if TEMPLATE_PAYLOAD['num'] != '1MNBD7MC': #改代码网页的部分字段为空，需要特殊处理
        for data in clean_data:
            clean_data_person += data['hs_Character']
        df_person = DataFrame(clean_data_person)
    else:
        df_person = None
    print(f'load total records:{rec_counts}')
    df_rank = DataFrame(clean_data)
    print(f'start writing files....')
    save_to_excel(dfs=[df_rank, df_person], file_name='胡润数据_民营500')

