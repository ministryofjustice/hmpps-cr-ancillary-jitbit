import asyncio
import inspect
import json
import math
import logging
import importlib
from datetime import datetime
from aws_synthetics.selenium import synthetics_webdriver as webdriver
from aws_synthetics.common import synthetics_logger as logger, CanaryStatus


def handler(event, context):
    return asyncio.run(handle_canary(event, context))


async def handle_canary(event, context):
    canary_result = CanaryStatus.NO_RESULT.value
    canary_error = None
    start_time = None
    reset_time = None
    setup_time = None
    launch_time = None
    try:
        # reset synthetics
        reset_time = datetime.now()
        await webdriver.reset()
        reset_time = (datetime.now() - reset_time).total_seconds() * 1000

        logger.info("Start canary")

        # setup
        setup_time = datetime.now()
        webdriver.set_event_and_context(event, context)

        # before canary
        await webdriver.before_canary()
        setup_time = (datetime.now() - setup_time).total_seconds() * 1000

        # launch
        launch_time = datetime.now()
        launch_time = (datetime.now() - launch_time).total_seconds() * 1000
    except Exception:
        logger.exception("Error launching canary")
        launch_time = launch_time if launch_time else datetime.now()
        start_time = datetime.now()
        end_time = start_time
        launch_time = (datetime.now() - launch_time).total_seconds() * 1000
        return_value = await webdriver.after_canary(canary_result, canary_error, start_time, end_time, reset_time,
                                                    setup_time, launch_time)
        logger.info("End Canary. Result %s" % json.dumps(return_value))
        # workflow expects null to be stringified
        return_value["testRunError"] = "null" if return_value["testRunError"] is None else return_value["testRunError"]
        return_value["executionError"] = "null" if return_value["executionError"] is None else return_value["executionError"]
        return json.dumps(return_value)

    # execute user steps
    try:
        logger.info("Start executing customer steps")
        start_time = datetime.now()
        customer_canary_handler = event["customerCanaryHandlerName"]
        file_name = None
        if customer_canary_handler is not None:
            # Assuming handler format: fileName.functionName
            file_name, function_name = customer_canary_handler.split(".")
            logger.info("Customer canary entry file name: %s" % file_name)
            logger.info("Customer canary entry function name: %s" % function_name)

        # Call customer's execution handler
        # Canary file is located under /opt/python/, but we can import it just by using file name
        # Python module finder automatically resolves to /opt/python/<filename>
        customer_canary = importlib.import_module(file_name)
        logger.info("Calling customer canary: %s.handler()" % file_name)
        if inspect.iscoroutinefunction(customer_canary.handler):
            response = await customer_canary.handler(event, context)
        else:
            response = customer_canary.handler(event, context)
        logger.info("Customer canary response %s" % json.dumps(response))
        end_time = datetime.now()
        canary_result = CanaryStatus.PASSED.value
        logger.info("Finished executing customer steps")
    except Exception as ex:
        end_time = datetime.now()
        canary_result = CanaryStatus.FAILED.value
        canary_error = ex
        logger.exception("Canary execution exception.")

    return_value = await webdriver.after_canary(canary_result, canary_error, start_time, end_time, reset_time, setup_time, launch_time)
    logger.info("End Canary. Result %s" % json.dumps(return_value))
    # workflow expects null to be stringified
    return_value["testRunError"] = "null" if return_value["testRunError"] is None else return_value["testRunError"]
    return_value["executionError"] = "null" if return_value["executionError"] is None else return_value["executionError"]
    return json.dumps(return_value)