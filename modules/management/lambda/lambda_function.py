import json
import boto3
import os
import datetime

def lambda_handler(event, context):
    client = boto3.client('elbv2')

    if os.environ['enable'] == "true":

        now = datetime.datetime.now()
        x = now.hour + 1
        if (x > int(os.environ['quiet_period_end_hour']) and x < int(os.environ['quiet_perod_start_hour'])):
            active_tg_response = client.describe_listeners(
                ListenerArns=[
                    os.environ['listener_arn'],
                ],
                Marker='string',
                PageSize=123
            )
            
            tg_a_arn = active_tg_response['Listeners'][0]['DefaultActions'][0]['ForwardConfig']['TargetGroups'][0]['TargetGroupArn']
            tg_a_weight = active_tg_response['Listeners'][0]['DefaultActions'][0]['ForwardConfig']['TargetGroups'][0]['Weight']
            tg_b_arn = active_tg_response['Listeners'][0]['DefaultActions'][0]['ForwardConfig']['TargetGroups'][1]['TargetGroupArn']
            tg_b_weight = active_tg_response['Listeners'][0]['DefaultActions'][0]['ForwardConfig']['TargetGroups'][1]['Weight']
            
            if tg_a_weight == 1:
                active_tg_arn = tg_b_arn
                active_tg_weight = tg_b_weight
                passive_tg_arn = tg_a_arn
                passive_tg_weight = tg_a_weight
            else:
                active_tg_arn = tg_a_arn
                active_tg_weight = tg_a_weight
                passive_tg_arn = tg_b_arn
                passive_tg_weight = tg_b_weight
            
            response = client.modify_listener(
                ListenerArn=os.environ['listener_arn'],
                DefaultActions=[
                    {
                        'Type': 'forward',
                        'ForwardConfig': {
                            'TargetGroups': [
                                {
                                    'TargetGroupArn': active_tg_arn,
                                    'Weight': 1
                                },
                                {
                                    'TargetGroupArn': passive_tg_arn,
                                    'Weight': 0
                                },
                            ],
                            'TargetGroupStickinessConfig': {
                                'Enabled': False,
                                'DurationSeconds': 1
                            }
                        },
                    },
                ],
            )
            print(response)
        else:
            print("inactive period - no action on failure")