import json
import os
import re
import argparse


def parse_iw(string):
    rex = re.compile('\d{1,3}/\d{1,3}')
    values = rex.findall(string)
    return json.dumps({'Link Quality': values[0], 'Signal level': values[1], 'Noise Level': values[2]})


def parse_ss(string):
    string = string.strip()
    string = string.replace("send ", "send:").replace("pacing_rate ", "pacing_rate:").replace("delivery_rate ",
                                                                                              "delivery_rate:")
    items = string.split()
    data = {}
    for item in items:
        if '(' in item and ')' in item and len(item) > 30:
            bbr_data = item.split('(')[1].split(')')[0]
            bbr_items = bbr_data.split(',')
            bbr_dict = {}
            for bbr_item in bbr_items:
                bbr_key, bbr_value = bbr_item.split(':')
                bbr_dict[bbr_key] = bbr_value
            data['bbr'] = bbr_dict
        elif ':' in item:
            key, value = item.split(':')
            data[key] = value
        else:
            data[item] = None
    return json.dumps(data)


def postprocessing_routine(log_type, base_path):
    for time in os.listdir(base_path):
        path_time = os.path.join(base_path, time)
        path_time_type = os.path.join(path_time, log_type)
        for file_name in filter(lambda e: ".raw" in e, os.listdir(path_time_type)):
            complete_input_path = os.path.join(path_time_type, file_name)
            complete_output_path = complete_input_path.replace(".raw", ".json")
            with open(complete_input_path, 'r') as input_file:
                with open(complete_output_path, 'w') as output_file:
                    try:
                        if log_type == "iw":
                            res = parse_iw(input_file.read())
                        elif log_type == "ss":
                            res = parse_ss(input_file.read())
                        output_file.write(res)
                        output_file.close()
                        input_file.close()
                    except:
                        print(complete_input_path)
                    else:
                        os.remove(complete_input_path)


parser = argparse.ArgumentParser()
parser.add_argument('path', type=str)
arg = parser.parse_args()
base_path = arg.path
postprocessing_routine("iw", base_path)
postprocessing_routine("ss", base_path)

