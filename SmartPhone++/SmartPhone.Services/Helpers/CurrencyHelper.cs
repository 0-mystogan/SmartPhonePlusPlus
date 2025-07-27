using System;
using System.Globalization;
using SmartPhone.Services.Database;

namespace SmartPhone.Services.Helpers
{
    public static class CurrencyHelper
    {
        public static string FormatPrice(decimal price, Currency currency)
        {
            if (currency == null)
                return price.ToString("C");

            var format = currency.DecimalPlaces switch
            {
                0 => "0",
                1 => "0.0",
                2 => "0.00",
                3 => "0.000",
                _ => "0.00"
            };

            var formattedPrice = price.ToString(format, CultureInfo.InvariantCulture);

            return currency.SymbolPosition?.ToLower() switch
            {
                "before" => $"{currency.Symbol}{formattedPrice}",
                "after" => $"{formattedPrice} {currency.Symbol}",
                _ => $"{currency.Symbol}{formattedPrice}"
            };
        }

        public static string FormatPrice(decimal price, string currencyCode, string currencySymbol, string symbolPosition = "Before")
        {
            var formattedPrice = price.ToString("0.00", CultureInfo.InvariantCulture);

            return symbolPosition?.ToLower() switch
            {
                "before" => $"{currencySymbol}{formattedPrice}",
                "after" => $"{formattedPrice} {currencySymbol}",
                _ => $"{currencySymbol}{formattedPrice}"
            };
        }

        public static decimal ConvertCurrency(decimal amount, decimal exchangeRate)
        {
            return Math.Round(amount * exchangeRate, 2, MidpointRounding.AwayFromZero);
        }

        public static bool IsValidCurrencyCode(string currencyCode)
        {
            if (string.IsNullOrWhiteSpace(currencyCode))
                return false;

            return currencyCode.Length == 3 && currencyCode.All(char.IsLetter);
        }
    }
} 