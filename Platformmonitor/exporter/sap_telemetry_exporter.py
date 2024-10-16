import os
import configparser
import pandas as pd
import time
import json
import requests
from prometheus_client.core import GaugeMetricFamily, REGISTRY, CounterMetricFamily
from prometheus_client import start_http_server

# config = configparser.ConfigParser()
# config.read("/exporter/config/config.ini")

systems = [
    'i1b', 'k1b', 'p1b', 'i3w', 'p3w', 'i8b', 'k8b', 'p8b'
]

MANDATORY_ENV_VARS = ["esb-subscription-key"]
for var in MANDATORY_ENV_VARS:
    if var not in os.environ:
        raise EnvironmentError("Failed because {} is not set.".format(var))

class read_telemetry(object):
    def __init__(self):
        pass
    def collect(self):
        for system in systems:
            try:
                response = requests.get('https://esb-dev.zeiss.com/public/api/platform-monitor/{}'.format(system),verify=False,headers={'EsbApi-Subscription-Key':os.environ['esb-subscription-key']})
                json_response = json.loads(response.content)
                df = pd.json_normalize(json_response['d']['results'])
                df = df[['Property','Source','Value']]
                df['System'] = system
                df['Source'] = df['Source'].fillna(df['System'])
            
                for row in df.itertuples():
                    if row.Property == 'MUI':
                        gauge_name = 'memory_util_instance_bytes'
                        gauge_description = 'Memory Utilization by Instance'
                        type = 'Gauge'
                    elif row.Property == 'MUP':
                        gauge_name = 'memory_util_instance_percent'
                        gauge_description = 'Memory Utilization in Percent'
                        type = 'Gauge'
                    elif row.Property == 'MUS':
                        gauge_name = 'memory_util_service'
                        gauge_description = 'Memory Utilization by HANA Service'
                        type = 'Gauge'
                    elif row.Property == 'AJC':
                        gauge_name = 'jobs_active_count'
                        gauge_description = 'Active Job Count'
                        type = 'Gauge'
                    elif row.Property == 'ASC':
                        gauge_name = 'sessions_count'
                        gauge_description = 'Active Session Count'
                        type = 'Gauge'
                    elif row.Property == 'CJC':
                        gauge_name = 'jobs_cancelled_count'
                        gauge_description = 'Cancelled Job Count'
                        type = 'Gauge'
                    elif row.Property == 'IDL':
                        gauge_name = 'cpu_idle_percent'
                        gauge_description = 'Appl. Server CPU Idle'
                        type = 'Gauge'
                    elif row.Property == 'MEM':
                        gauge_name = 'memory_util_app_server_percent'
                        gauge_description = 'Memory Utilization Application Server'
                        type = 'Gauge'
                    elif row.Property == 'STA':
                        gauge_name = 'sdi_tasks_active'
                        gauge_description = 'SDI Tasks Active'
                        type = 'Gauge'
                    elif row.Property == 'STF':
                        gauge_name = 'sdi_tasks_failed'
                        gauge_description = 'SDI Tasks Failed'
                        type = 'Gauge'
                    elif row.Property == 'MOD':
                        gauge_name = 'system_not_closed'
                        gauge_description = 'System not closed properly'
                        type = 'Gauge'
                        
                    if type == 'Gauge':                        
                        gauge = GaugeMetricFamily(gauge_name, gauge_description, labels=['System','Source'])
                        gauge.add_metric([row.System,row.Source], row.Value)
                        yield gauge
                
            except:
                print( '..... ' + system + ' is unreachable becouse of')
                print(response.status_code)

if __name__ == '__main__':
    port = 9080
    frequency = 5
    start_http_server(port)
    REGISTRY.register(read_telemetry())
    while True:
        time.sleep(frequency)