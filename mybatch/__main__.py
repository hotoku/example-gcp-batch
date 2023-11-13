import logging
from datetime import date

import click

LOGGER = logging.getLogger(__name__)


@click.command()
@click.option("--start-date", type=str)
@click.option("--end-date", type=str)
def main(start_date: date, end_date: date):
    print("start")
    print("BATCH_TASK_COUNT", os.getenv("BATCH_TASK_COUNT"))
    print("BATCH_TASK_INDEX", os.getenv("BATCH_TASK_INDEX"))
    print("start_date", start_date)
    print("end_date", end_date)


if __name__ == "__main__":
    main()
