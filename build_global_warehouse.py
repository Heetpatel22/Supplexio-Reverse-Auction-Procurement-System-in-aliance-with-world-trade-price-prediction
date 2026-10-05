from global_trade_loader import get_global_trade_data


def main():
    data = get_global_trade_data(force_refresh=True)
    print("Global trade warehouse ready")
    print({key: len(value) for key, value in data.items()})


if __name__ == "__main__":
    main()
