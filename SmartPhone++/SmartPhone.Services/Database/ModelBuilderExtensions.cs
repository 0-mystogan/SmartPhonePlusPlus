using SmartPhone.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace SmartPhone.Services.Database
{
    public static class ModelBuilderExtensions
    {
        private const string DefaultPhoneNumber = "+387 62 667 961";
        
        private const string TestMailSender = "smartphoneplusplus.sender@gmail.com";
        private const string TestMailReceiver = "panzermystogan@gmail.com";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc);

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role 
                { 
                    Id = 1, 
                    Name = "Administrator", 
                    Description = "System administrator with full access", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                },
                new Role 
                { 
                    Id = 2, 
                    Name = "User", 
                    Description = "Standard user role", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                }
            );

            // Seed Users
            modelBuilder.Entity<User>().HasData(
                new User 
                { 
                    Id = 1, 
                    FirstName = "Denis", 
                    LastName = "Mušić", 
                    Email = TestMailReceiver, 
                    Username = "admin", 
                    PasswordHash = "3KbrBi5n9zdQnceWWOK5zaeAwfEjsluyhRQUbNkcgLQ=", 
                    PasswordSalt = "6raKZCuEsvnBBxPKHGpRtA==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Sarajevo
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "10.png")
                },
                new User 
                { 
                    Id = 2, 
                    FirstName = "Amel", 
                    LastName = "Musić",
                    Email = "example1@gmail.com",
                    Username = "user", 
                    PasswordHash = "kDPVcZaikiII7vXJbMEw6B0xZ245I29ocaxBjLaoAC0=", 
                    PasswordSalt = "O5R9WmM6IPCCMci/BCG/eg==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Banja Luka
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "11.png")
                }
            );

            // Seed UserRoles
            modelBuilder.Entity<UserRole>().HasData(
                new UserRole 
                { 
                    Id = 1, 
                    UserId = 1, 
                    RoleId = 1, 
                    DateAssigned = fixedDate // Admin user with Administrator role
                },
                new UserRole 
                { 
                    Id = 2, 
                    UserId = 2, 
                    RoleId = 2, 
                    DateAssigned = fixedDate // Driver One with Driver role
                }
            );

       
            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed Cities
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Sarajevo" },
                new City { Id = 2, Name = "Banja Luka" },
                new City { Id = 3, Name = "Tuzla" },
                new City { Id = 4, Name = "Zenica" },
                new City { Id = 5, Name = "Mostar" },
                new City { Id = 6, Name = "Bihać" },
                new City { Id = 7, Name = "Brčko" },
                new City { Id = 8, Name = "Bijeljina" },
                new City { Id = 9, Name = "Prijedor" },
                new City { Id = 10, Name = "Trebinje" },
                new City { Id = 11, Name = "Doboj" },
                new City { Id = 12, Name = "Cazin" },
                new City { Id = 13, Name = "Velika Kladuša" },
                new City { Id = 14, Name = "Visoko" },
                new City { Id = 15, Name = "Zavidovići" },
                new City { Id = 16, Name = "Gračanica" },
                new City { Id = 17, Name = "Konjic" },
                new City { Id = 18, Name = "Livno" },
                new City { Id = 19, Name = "Srebrenik" },
                new City { Id = 20, Name = "Gradačac" }
            );



            // Seed Currencies
            modelBuilder.Entity<Currency>().HasData(
                new Currency { Id = 1, Code = "USD", Name = "US Dollar", Symbol = "$", SymbolPosition = "Before", DecimalPlaces = 2, IsActive = true, IsDefault = true, CreatedAt = fixedDate },
                new Currency { Id = 2, Code = "EUR", Name = "Euro", Symbol = "€", SymbolPosition = "Before", DecimalPlaces = 2, IsActive = true, IsDefault = false, CreatedAt = fixedDate },
                new Currency { Id = 3, Code = "BAM", Name = "Bosnia and Herzegovina Convertible Mark", Symbol = "KM", SymbolPosition = "After", DecimalPlaces = 2, IsActive = true, IsDefault = false, CreatedAt = fixedDate },
                new Currency { Id = 4, Code = "GBP", Name = "British Pound", Symbol = "£", SymbolPosition = "Before", DecimalPlaces = 2, IsActive = true, IsDefault = false, CreatedAt = fixedDate },
                new Currency { Id = 5, Code = "CHF", Name = "Swiss Franc", Symbol = "CHF", SymbolPosition = "Before", DecimalPlaces = 2, IsActive = true, IsDefault = false, CreatedAt = fixedDate }
            );

            // Seed eCommerce Categories
            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Smartphones", Description = "Latest smartphones and mobile devices", IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 2, Name = "Tablets", Description = "Tablets and iPads", IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 3, Name = "Laptops", Description = "Laptops and notebooks", IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 4, Name = "Accessories", Description = "Phone and device accessories", IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 5, Name = "Phone Cases", Description = "Protective cases for phones", ParentCategoryId = 4, IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 6, Name = "Chargers", Description = "Charging cables and adapters", ParentCategoryId = 4, IsActive = true, CreatedAt = fixedDate }
            );

            // Seed eCommerce Products
            modelBuilder.Entity<Product>().HasData(
                new Product 
                { 
                    Id = 1, 
                    Name = "iPhone 15 Pro", 
                    Description = "Latest iPhone with A17 Pro chip", 
                    StockQuantity = 50, 
                    SKU = "IPH15PRO-128", 
                    Brand = "Apple", 
                    Model = "iPhone 15 Pro", 
                    Color = "Natural Titanium", 
                    CategoryId = 1, 
                    IsActive = true, 
                    IsFeatured = true, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 2, 
                    Name = "Samsung Galaxy S24 Ultra", 
                    Description = "Premium Android smartphone with S Pen", 
                    StockQuantity = 30, 
                    SKU = "SAMS24ULT-256", 
                    Brand = "Samsung", 
                    Model = "Galaxy S24 Ultra", 
                    Color = "Titanium Black", 
                    CategoryId = 1, 
                    IsActive = true, 
                    IsFeatured = true, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 3, 
                    Name = "iPad Air 5th Generation", 
                    Description = "Powerful tablet for work and creativity", 
                    StockQuantity = 25, 
                    SKU = "IPADAIR5-64", 
                    Brand = "Apple", 
                    Model = "iPad Air", 
                    Color = "Space Gray", 
                    CategoryId = 2, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 4, 
                    Name = "MacBook Air M2", 
                    Description = "Ultra-thin laptop with M2 chip", 
                    StockQuantity = 20, 
                    SKU = "MBAIRM2-256", 
                    Brand = "Apple", 
                    Model = "MacBook Air", 
                    Color = "Silver", 
                    CategoryId = 3, 
                    IsActive = true, 
                    IsFeatured = true, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 5, 
                    Name = "iPhone 15 Pro Case", 
                    Description = "Premium protective case for iPhone 15 Pro", 
                    StockQuantity = 100, 
                    SKU = "CASE-IPH15PRO", 
                    Brand = "SmartPhone++", 
                    Model = "Premium Case", 
                    Color = "Clear", 
                    CategoryId = 5, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                }
            );

            // Seed Product Prices (Multi-currency)
            modelBuilder.Entity<ProductPrice>().HasData(
                // iPhone 15 Pro prices
                new ProductPrice { Id = 1, ProductId = 1, CurrencyId = 1, Price = 999.99m, IsActive = true, CreatedAt = fixedDate }, // USD
                new ProductPrice { Id = 2, ProductId = 1, CurrencyId = 2, Price = 899.99m, IsActive = true, CreatedAt = fixedDate }, // EUR
                new ProductPrice { Id = 3, ProductId = 1, CurrencyId = 3, Price = 1750.00m, IsActive = true, CreatedAt = fixedDate }, // BAM
                
                // Samsung Galaxy S24 Ultra prices
                new ProductPrice { Id = 4, ProductId = 2, CurrencyId = 1, Price = 1199.99m, IsActive = true, CreatedAt = fixedDate }, // USD
                new ProductPrice { Id = 5, ProductId = 2, CurrencyId = 2, Price = 1099.99m, IsActive = true, CreatedAt = fixedDate }, // EUR
                new ProductPrice { Id = 6, ProductId = 2, CurrencyId = 3, Price = 2100.00m, IsActive = true, CreatedAt = fixedDate }, // BAM
                
                // iPad Air prices
                new ProductPrice { Id = 7, ProductId = 3, CurrencyId = 1, Price = 599.99m, IsActive = true, CreatedAt = fixedDate }, // USD
                new ProductPrice { Id = 8, ProductId = 3, CurrencyId = 2, Price = 549.99m, IsActive = true, CreatedAt = fixedDate }, // EUR
                new ProductPrice { Id = 9, ProductId = 3, CurrencyId = 3, Price = 1050.00m, IsActive = true, CreatedAt = fixedDate }, // BAM
                
                // MacBook Air M2 prices
                new ProductPrice { Id = 10, ProductId = 4, CurrencyId = 1, Price = 1099.99m, IsActive = true, CreatedAt = fixedDate }, // USD
                new ProductPrice { Id = 11, ProductId = 4, CurrencyId = 2, Price = 999.99m, IsActive = true, CreatedAt = fixedDate }, // EUR
                new ProductPrice { Id = 12, ProductId = 4, CurrencyId = 3, Price = 1925.00m, IsActive = true, CreatedAt = fixedDate }, // BAM
                
                // iPhone 15 Pro Case prices
                new ProductPrice { Id = 13, ProductId = 5, CurrencyId = 1, Price = 49.99m, IsActive = true, CreatedAt = fixedDate }, // USD
                new ProductPrice { Id = 14, ProductId = 5, CurrencyId = 2, Price = 44.99m, IsActive = true, CreatedAt = fixedDate }, // EUR
                new ProductPrice { Id = 15, ProductId = 5, CurrencyId = 3, Price = 87.50m, IsActive = true, CreatedAt = fixedDate } // BAM
            );

            // Seed eCommerce Coupons
            modelBuilder.Entity<Coupon>().HasData(
                new Coupon 
                { 
                    Id = 1, 
                    Code = "WELCOME10", 
                    Name = "Welcome Discount", 
                    Description = "10% off for new customers", 
                    DiscountAmount = 10, 
                    DiscountType = "Percentage", 
                    MaximumDiscountAmount = 100, 
                    MinimumOrderAmount = 50, 
                    ValidFrom = fixedDate, 
                    ValidTo = fixedDate.AddYears(1), 
                    MaximumUses = 1000, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Coupon 
                { 
                    Id = 2, 
                    Code = "SAVE20", 
                    Name = "20% Off Sale", 
                    Description = "20% off on all products", 
                    DiscountAmount = 20, 
                    DiscountType = "Percentage", 
                    MaximumDiscountAmount = 200, 
                    MinimumOrderAmount = 100, 
                    ValidFrom = fixedDate, 
                    ValidTo = fixedDate.AddMonths(3), 
                    MaximumUses = 500, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                }
            );

            // Seed Parts Management Data
            
            // Seed Part Categories
            modelBuilder.Entity<PartCategory>().HasData(
                new PartCategory { Id = 1, Name = "Screens & Displays", Description = "Phone screens, LCD panels, digitizers", IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 2, Name = "Batteries", Description = "Phone batteries and power components", IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 3, Name = "Charging Ports", Description = "USB-C, Lightning, and wireless charging components", IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 4, Name = "Cameras", Description = "Front and rear camera modules", IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 5, Name = "Speakers & Audio", Description = "Speakers, microphones, audio components", IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 6, Name = "Housings & Cases", Description = "Phone housings, frames, and cases", IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 7, Name = "Logic Boards", Description = "Motherboards and main circuit boards", IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 8, Name = "LCD Screens", Description = "LCD display panels", ParentCategoryId = 1, IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 9, Name = "Digitizers", Description = "Touch screen digitizers", ParentCategoryId = 1, IsActive = true, CreatedAt = fixedDate },
                new PartCategory { Id = 10, Name = "Screen Assemblies", Description = "Complete screen assemblies", ParentCategoryId = 1, IsActive = true, CreatedAt = fixedDate }
            );

            // Seed Phone Models
            modelBuilder.Entity<PhoneModel>().HasData(
                new PhoneModel { Id = 1, Brand = "Apple", Model = "iPhone 15 Pro", Series = "Pro", Year = "2024", Storage = "128GB", RAM = "8GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 2, Brand = "Apple", Model = "iPhone 15 Pro", Series = "Pro", Year = "2024", Storage = "256GB", RAM = "8GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 3, Brand = "Samsung", Model = "Galaxy S24 Ultra", Series = "Ultra", Year = "2024", Storage = "256GB", RAM = "12GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 4, Brand = "Samsung", Model = "Galaxy S24 Ultra", Series = "Ultra", Year = "2024", Storage = "512GB", RAM = "12GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 5, Brand = "Apple", Model = "iPhone 14 Pro", Series = "Pro", Year = "2023", Storage = "128GB", RAM = "6GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 6, Brand = "Samsung", Model = "Galaxy S23 Ultra", Series = "Ultra", Year = "2023", Storage = "256GB", RAM = "12GB", Network = "5G", IsActive = true, CreatedAt = fixedDate }
            );

            // Seed Parts
            modelBuilder.Entity<Part>().HasData(
                new Part 
                { 
                    Id = 1, 
                    Name = "iPhone 15 Pro LCD Screen", 
                    Description = "Original LCD screen for iPhone 15 Pro", 
                    Price = 299.99m, 
                    CostPrice = 180.00m, 
                    StockQuantity = 25, 
                    MinimumStockLevel = 5, 
                    SKU = "IPH15PRO-LCD", 
                    PartNumber = "A2848-LCD", 
                    Brand = "Apple", 
                    Model = "iPhone 15 Pro", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 8, 
                    CreatedAt = fixedDate 
                },
                new Part 
                { 
                    Id = 2, 
                    Name = "iPhone 15 Pro Battery", 
                    Description = "High-capacity battery for iPhone 15 Pro", 
                    Price = 89.99m, 
                    CostPrice = 45.00m, 
                    StockQuantity = 50, 
                    MinimumStockLevel = 10, 
                    SKU = "IPH15PRO-BAT", 
                    PartNumber = "A2848-BAT", 
                    Brand = "Apple", 
                    Model = "iPhone 15 Pro", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 2, 
                    CreatedAt = fixedDate 
                },
                new Part 
                { 
                    Id = 3, 
                    Name = "Samsung S24 Ultra Screen Assembly", 
                    Description = "Complete screen assembly for Galaxy S24 Ultra", 
                    Price = 399.99m, 
                    CostPrice = 250.00m, 
                    StockQuantity = 15, 
                    MinimumStockLevel = 3, 
                    SKU = "SAMS24ULT-SCR", 
                    PartNumber = "SM-S928-SCR", 
                    Brand = "Samsung", 
                    Model = "Galaxy S24 Ultra", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 10, 
                    CreatedAt = fixedDate 
                },
                new Part 
                { 
                    Id = 4, 
                    Name = "iPhone 15 Pro Charging Port", 
                    Description = "USB-C charging port for iPhone 15 Pro", 
                    Price = 49.99m, 
                    CostPrice = 25.00m, 
                    StockQuantity = 30, 
                    MinimumStockLevel = 8, 
                    SKU = "IPH15PRO-USB", 
                    PartNumber = "A2848-USB", 
                    Brand = "Apple", 
                    Model = "iPhone 15 Pro", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 3, 
                    CreatedAt = fixedDate 
                },
                new Part 
                { 
                    Id = 5, 
                    Name = "Samsung S24 Ultra Camera Module", 
                    Description = "200MP main camera module for Galaxy S24 Ultra", 
                    Price = 199.99m, 
                    CostPrice = 120.00m, 
                    StockQuantity = 20, 
                    MinimumStockLevel = 5, 
                    SKU = "SAMS24ULT-CAM", 
                    PartNumber = "SM-S928-CAM", 
                    Brand = "Samsung", 
                    Model = "Galaxy S24 Ultra", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 4, 
                    CreatedAt = fixedDate 
                }
            );

            // Seed Part Compatibilities
            modelBuilder.Entity<PartCompatibility>().HasData(
                new PartCompatibility { Id = 1, PartId = 1, PhoneModelId = 1, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 2, PartId = 1, PhoneModelId = 2, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 3, PartId = 2, PhoneModelId = 1, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 4, PartId = 2, PhoneModelId = 2, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 5, PartId = 3, PhoneModelId = 3, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 6, PartId = 3, PhoneModelId = 4, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 7, PartId = 4, PhoneModelId = 1, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 8, PartId = 4, PhoneModelId = 2, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 9, PartId = 5, PhoneModelId = 3, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 10, PartId = 5, PhoneModelId = 4, IsVerified = true, CreatedAt = fixedDate }
            );

            // Seed Services
            modelBuilder.Entity<Service>().HasData(
                new Service 
                { 
                    Id = 1, 
                    Name = "Samsung S21 - Broken Glass", 
                    Description = "Screen replacement for Samsung Galaxy S21", 
                    ServiceFee = 150.00m, 
                    EstimatedDuration = 2.0m, 
                    Status = "Pending", 
                    UserId = 1, 
                    PhoneModelId = 6, 
                    CreatedAt = fixedDate 
                },
                new Service 
                { 
                    Id = 2, 
                    Name = "iPhone 15 Pro - Fried Chip", 
                    Description = "Logic board repair for iPhone 15 Pro", 
                    ServiceFee = 300.00m, 
                    EstimatedDuration = 4.0m, 
                    Status = "Pending", 
                    UserId = 2, 
                    PhoneModelId = 1, 
                    CreatedAt = fixedDate 
                },
                new Service 
                { 
                    Id = 3, 
                    Name = "Xiaomi 13 Pro Plus - Slow", 
                    Description = "Performance optimization and battery replacement", 
                    ServiceFee = 120.00m, 
                    EstimatedDuration = 1.5m, 
                    Status = "Pending", 
                    UserId = 1, 
                    CreatedAt = fixedDate 
                }
            );

        }


    }
} 