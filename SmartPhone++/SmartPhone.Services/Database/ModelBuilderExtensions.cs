using SmartPhone.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace SmartPhone.Services.Database
{
    public static class ModelBuilderExtensions
    {
        private const string DefaultPhoneNumber = "+387 64 40 65 969";
        
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
                },
                 new Role
                 {
                    Id = 3,
                    Name = "Technician",
                    Description = "Technician role for services and parts",
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
                    PasswordHash = "3KbrBi5n9zdQnceWWOK5zaeAwfEjsluyhRQUbNkcgLQ=", //test
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
                    Username = "ameltech", 
                    PasswordHash = "n9yGhSv6sNNKNNMG3uAVpN0YWDZGeVRz2Te3MsESj0I=", //ameltech123
                    PasswordSalt = "E2d9m5yJ2+VWXK1FF4NTOw==", 
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
                    RoleId = 3, 
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

            // Seed eCommerce Categories
            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Smartphones", Description = "Latest smartphones and mobile devices", IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 2, Name = "Tablets", Description = "Tablets and iPads", IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 3, Name = "Laptops", Description = "Laptops and notebooks", IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 4, Name = "Accessories", Description = "Phone and device accessories", IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 5, Name = "Phone Cases", Description = "Protective cases for phones", ParentCategoryId = 4, IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 6, Name = "Chargers", Description = "Charging cables and adapters", ParentCategoryId = 4, IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 7, Name = "Audio", Description = "Headphones, earbuds, and audio accessories", ParentCategoryId = 4, IsActive = true, CreatedAt = fixedDate },
                new Category { Id = 8, Name = "Screen Protectors", Description = "Tempered glass and film protectors", ParentCategoryId = 4, IsActive = true, CreatedAt = fixedDate }
            );

            // Seed eCommerce Products
            modelBuilder.Entity<Product>().HasData(
                new Product 
                { 
                    Id = 1, 
                    Name = "iPhone 15 Pro", 
                    Description = "Latest iPhone with A17 Pro chip", 
                    Price = 999.99m,
                    DiscountedPrice = 899.99m,
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
                    Price = 1199.99m,
                    DiscountedPrice = 1099.99m,
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
                    Price = 599.99m,
                    DiscountedPrice = 549.99m,
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
                // Samsung Galaxy A Series Products
                new Product 
                { 
                    Id = 11, 
                    Name = "Samsung Galaxy A36", 
                    Description = "Affordable smartphone with great performance", 
                    Price = 199.99m,
                    DiscountedPrice = 179.99m,
                    StockQuantity = 40, 
                    SKU = "SAMSUNG-A36-64", 
                    Brand = "Samsung", 
                    Model = "Galaxy A36", 
                    Color = "Black", 
                    CategoryId = 1, 
                    IsActive = true, 
                    IsFeatured = true, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 12, 
                    Name = "Samsung Galaxy S25", 
                    Description = "Mid-range smartphone with excellent camera", 
                    Price = 299.99m,
                    DiscountedPrice = 269.99m,
                    StockQuantity = 35, 
                    SKU = "SAMSUNG-S25-128", 
                    Brand = "Samsung", 
                    Model = "Galaxy S25", 
                    Color = "Blue", 
                    CategoryId = 1, 
                    IsActive = true, 
                    IsFeatured = true, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 13, 
                    Name = "Samsung Galaxy A56", 
                    Description = "Budget-friendly smartphone with reliable performance", 
                    Price = 249.99m,
                    DiscountedPrice = 229.99m,
                    StockQuantity = 45, 
                    SKU = "SAMSUNG-A56-128", 
                    Brand = "Samsung", 
                    Model = "Galaxy A56", 
                    Color = "Gray", 
                    CategoryId = 1, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                },
                // Accessories and complementary products for testing recommendations
                new Product 
                { 
                    Id = 4, 
                    Name = "iPhone 15 Pro Case", 
                    Description = "Premium protective case for iPhone 15 Pro", 
                    Price = 49.99m,
                    StockQuantity = 100, 
                    SKU = "IPH15PRO-CASE", 
                    Brand = "Apple", 
                    Model = "iPhone 15 Pro", 
                    Color = "Clear", 
                    CategoryId = 5, 
                    IsActive = true, 
                    IsFeatured = true, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 5, 
                    Name = "Samsung S24 Ultra Case", 
                    Description = "Protective case for Samsung Galaxy S24 Ultra", 
                    Price = 39.99m,
                    StockQuantity = 80, 
                    SKU = "SAMS24ULT-CASE", 
                    Brand = "Samsung", 
                    Model = "Galaxy S24 Ultra", 
                    Color = "Black", 
                    CategoryId = 5, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 6, 
                    Name = "Samsung S24 Ultra Glass Protector", 
                    Description = "Tempered glass screen protector for S24 Ultra", 
                    Price = 19.99m,
                    StockQuantity = 150, 
                    SKU = "SAMS24ULT-GLASS", 
                    Brand = "Samsung", 
                    Model = "Galaxy S24 Ultra", 
                    Color = "Clear", 
                    CategoryId = 8, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 7, 
                    Name = "Fast Charger 25W", 
                    Description = "25W fast charger compatible with Samsung devices", 
                    Price = 29.99m,
                    StockQuantity = 75, 
                    SKU = "CHARGER-25W", 
                    Brand = "Samsung", 
                    Model = "Fast Charger", 
                    Color = "White", 
                    CategoryId = 6, 
                    IsActive = true, 
                    IsFeatured = true, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 8, 
                    Name = "Samsung Galaxy Buds2 Pro", 
                    Description = "Premium wireless earbuds with active noise cancellation", 
                    Price = 199.99m,
                    StockQuantity = 40, 
                    SKU = "BUDS2PRO", 
                    Brand = "Samsung", 
                    Model = "Galaxy Buds2 Pro", 
                    Color = "Graphite", 
                    CategoryId = 7, 
                    IsActive = true, 
                    IsFeatured = true, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 9, 
                    Name = "iPhone 15 Pro Glass Protector", 
                    Description = "Tempered glass screen protector for iPhone 15 Pro", 
                    Price = 24.99m,
                    StockQuantity = 120, 
                    SKU = "IPH15PRO-GLASS", 
                    Brand = "Apple", 
                    Model = "iPhone 15 Pro", 
                    Color = "Clear", 
                    CategoryId = 8, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 10, 
                    Name = "Wireless Charging Pad", 
                    Description = "15W wireless charging pad for all Qi-compatible devices", 
                    Price = 34.99m,
                    StockQuantity = 60, 
                    SKU = "WIRELESS-CHARGER", 
                    Brand = "Generic", 
                    Model = "Wireless Charger", 
                    Color = "Black", 
                    CategoryId = 6, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                },
                // Samsung Galaxy A Series Accessories
                new Product 
                { 
                    Id = 14, 
                    Name = "Samsung Galaxy A56 MagSafe Case", 
                    Description = "Premium MagSafe compatible case for Galaxy A56", 
                    Price = 29.99m,
                    StockQuantity = 60, 
                    SKU = "SAMSUNG-A56-MAGSAFE", 
                    Brand = "Samsung", 
                    Model = "Galaxy A56", 
                    Color = "Black", 
                    CategoryId = 5, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 15, 
                    Name = "Samsung Galaxy A56 Glass Protector", 
                    Description = "9D tempered glass screen protector for Galaxy A56", 
                    Price = 14.99m,
                    StockQuantity = 80, 
                    SKU = "SAMSUNG-A56-GLASS", 
                    Brand = "Samsung", 
                    Model = "Galaxy A56", 
                    Color = "Clear", 
                    CategoryId = 8, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                },
                new Product 
                { 
                    Id = 16, 
                    Name = "Samsung Galaxy A56 Black Case", 
                    Description = "Slim protective case for Galaxy A56", 
                    Price = 19.99m,
                    StockQuantity = 70, 
                    SKU = "SAMSUNG-A56-CASE-BLACK", 
                    Brand = "Samsung", 
                    Model = "Galaxy A56", 
                    Color = "Black", 
                    CategoryId = 5, 
                    IsActive = true, 
                    IsFeatured = false, 
                    CreatedAt = fixedDate 
                }
            );

            // Seed Product Images
            modelBuilder.Entity<ProductImage>().HasData(
                new ProductImage 
                { 
                    Id = 1, 
                    ProductId = 1, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "iphone15pro.jpg") ?? new byte[0],
                    FileName = "iphone15pro.jpg",
                    ContentType = "image/jpeg",
                    AltText = "iPhone 15 Pro",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 2, 
                    ProductId = 2, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "samsung-s24-ultra.jpg") ?? new byte[0],
                    FileName = "samsung-s24-ultra.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy S24 Ultra",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 3, 
                    ProductId = 2, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "samsung-s24-ultra-2.jpg") ?? new byte[0],
                    FileName = "samsung-s24-ultra-2.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy S24 Ultra - Back View",
                    IsPrimary = false,
                    DisplayOrder = 2,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 4, 
                    ProductId = 3, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ipad-air.jpg") ?? new byte[0],
                    FileName = "ipad-air.jpg",
                    ContentType = "image/jpeg",
                    AltText = "iPad Air 5th Generation",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                // Samsung Galaxy A Series Product Images
                new ProductImage 
                { 
                    Id = 17, 
                    ProductId = 11, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "a36.jpg") ?? new byte[0],
                    FileName = "a36.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy A36",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 18, 
                    ProductId = 11, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "a36-2.jpg") ?? new byte[0],
                    FileName = "a36-2.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy A36 - Side View",
                    IsPrimary = false,
                    DisplayOrder = 2,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 19, 
                    ProductId = 11, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "a36-3.jpg") ?? new byte[0],
                    FileName = "a36-3.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy A36 - Back View",
                    IsPrimary = false,
                    DisplayOrder = 3,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 20, 
                    ProductId = 12, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "s25.jpg") ?? new byte[0],
                    FileName = "s25.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy S25",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 21, 
                    ProductId = 12, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "s25-2.jpg") ?? new byte[0],
                    FileName = "s25-2.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy S25 - Side View",
                    IsPrimary = false,
                    DisplayOrder = 2,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 22, 
                    ProductId = 12, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "s25-3.jpg") ?? new byte[0],
                    FileName = "s25-3.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy S25 - Back View",
                    IsPrimary = false,
                    DisplayOrder = 3,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 23, 
                    ProductId = 13, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "a56.jpg") ?? new byte[0],
                    FileName = "a56.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy A56",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 24, 
                    ProductId = 13, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "a56-2.jpg") ?? new byte[0],
                    FileName = "a56-2.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy A56 - Side View",
                    IsPrimary = false,
                    DisplayOrder = 2,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 25, 
                    ProductId = 13, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "a56-3.jpg") ?? new byte[0],
                    FileName = "a56-3.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy A56 - Back View",
                    IsPrimary = false,
                    DisplayOrder = 3,
                    CreatedAt = fixedDate 
                },
                // Product images for accessories and complementary products
                new ProductImage 
                { 
                    Id = 5, 
                    ProductId = 4, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "iphone15pro-case.jpg") ?? new byte[0],
                    FileName = "iphone15pro-case.jpg",
                    ContentType = "image/jpeg",
                    AltText = "iPhone 15 Pro Case",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 6, 
                    ProductId = 5, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "caseblack24ultra.jpg") ?? new byte[0],
                    FileName = "caseblack24ultra.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung S24 Ultra Case",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 7, 
                    ProductId = 6, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "glassS24ultra.jpg") ?? new byte[0],
                    FileName = "glassS24ultra.jpg", 
                    ContentType = "image/jpeg",
                    AltText = "Samsung S24 Ultra Glass Protector",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 8, 
                    ProductId = 7, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "samsung-charger-type c.jpg") ?? new byte[0],
                    FileName = "samsung-charger-type c.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Fast Charger 25W",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 9, 
                    ProductId = 8, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "samsung-buds2pro.jpg") ?? new byte[0],
                    FileName = "samsung-buds2pro.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy Buds2 Pro",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 10, 
                    ProductId = 9, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "iphone15pro-glass.jpg") ?? new byte[0],
                    FileName = "iphone15pro-glass.jpg",
                    ContentType = "image/jpeg",
                    AltText = "iPhone 15 Pro Glass Protector",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 11, 
                    ProductId = 10, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "wirelesscharger1.jpg") ?? new byte[0],
                    FileName = "wireless-charger.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Wireless Charging Pad",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                // Samsung Galaxy A Series Accessory Images
                new ProductImage 
                { 
                    Id = 26, 
                    ProductId = 14, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "magsafecaseA56.jpg") ?? new byte[0],
                    FileName = "magsafecaseA56.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy A56 MagSafe Case",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 27, 
                    ProductId = 15, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "Glass9Da56.jpg") ?? new byte[0],
                    FileName = "Glass9Da56.jpg",
                    ContentType = "image/jpeg",
                    AltText = "Samsung Galaxy A56 Glass Protector",
                    IsPrimary = true,
                    DisplayOrder = 1,
                    CreatedAt = fixedDate 
                },
                new ProductImage 
                { 
                    Id = 28, 
                    ProductId = 16, 
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "caseblackA56.jpg") ?? new byte[0],
                    FileName = "caseblackA56.jpg",
                    ContentType = "image/webp",
                    AltText = "Samsung Galaxy A56 Black Case",
                    IsPrimary = true,
                    DisplayOrder = 1,
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
                new PhoneModel { Id = 2, Brand = "Apple", Model = "iPhone 14 Pro", Series = "Pro", Year = "2023", Storage = "256GB", RAM = "8GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 3, Brand = "Samsung", Model = "Galaxy S24 Ultra", Series = "Ultra", Year = "2024", Storage = "256GB", RAM = "12GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 4, Brand = "Samsung", Model = "Galaxy S23 Ultra", Series = "Ultra", Year = "2023", Storage = "256GB", RAM = "12GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                // Xiaomi Note Series
                new PhoneModel { Id = 5, Brand = "Xiaomi", Model = "Redmi Note 11 Pro", Series = "Note", Year = "2023", Storage = "128GB", RAM = "8GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 6, Brand = "Xiaomi", Model = "Redmi Note 12 Pro", Series = "Note", Year = "2023", Storage = "128GB", RAM = "8GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 7, Brand = "Xiaomi", Model = "Redmi Note 10 Pro", Series = "Note", Year = "2022", Storage = "128GB", RAM = "8GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                // Samsung Galaxy A Series
                new PhoneModel { Id = 8, Brand = "Samsung", Model = "Galaxy A36", Series = "A", Year = "2023", Storage = "128GB", RAM = "6GB", Network = "4G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 9, Brand = "Samsung", Model = "Galaxy A56", Series = "A", Year = "2024", Storage = "128GB", RAM = "6GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 10, Brand = "Samsung", Model = "Galaxy A25", Series = "A", Year = "2024", Storage = "128GB", RAM = "6GB", Network = "5G", IsActive = true, CreatedAt = fixedDate },
                new PhoneModel { Id = 11, Brand = "Samsung", Model = "Galaxy A15", Series = "A", Year = "2024", Storage = "128GB", RAM = "6GB", Network = "5G", IsActive = true, CreatedAt = fixedDate }
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
                },
                // Xiaomi Redmi Note Series Parts
                new Part 
                { 
                    Id = 6, 
                    Name = "Xiaomi Redmi Note 11 Pro Battery", 
                    Description = "High-capacity battery for Redmi Note 11 Pro", 
                    Price = 69.99m, 
                    CostPrice = 35.00m, 
                    StockQuantity = 30, 
                    MinimumStockLevel = 8, 
                    SKU = "XIAOMI-NOTE11PRO-BAT", 
                    PartNumber = "RN11PRO-BAT", 
                    Brand = "Xiaomi", 
                    Model = "Redmi Note 11 Pro", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 2, 
                    CreatedAt = fixedDate 
                },
                new Part 
                { 
                    Id = 7, 
                    Name = "Xiaomi Redmi Note 12 Pro Screen Assembly", 
                    Description = "Complete screen assembly for Redmi Note 12 Pro", 
                    Price = 149.99m, 
                    CostPrice = 90.00m, 
                    StockQuantity = 20, 
                    MinimumStockLevel = 5, 
                    SKU = "XIAOMI-NOTE12PRO-SCR", 
                    PartNumber = "RN12PRO-SCR", 
                    Brand = "Xiaomi", 
                    Model = "Redmi Note 12 Pro", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 10, 
                    CreatedAt = fixedDate 
                },
                // Samsung Galaxy A Series Parts
                new Part 
                { 
                    Id = 8, 
                    Name = "Samsung Galaxy A36 LCD Screen", 
                    Description = "Original LCD screen for Galaxy A36", 
                    Price = 89.99m, 
                    CostPrice = 55.00m, 
                    StockQuantity = 35, 
                    MinimumStockLevel = 10, 
                    SKU = "SAMSUNG-A36-LCD", 
                    PartNumber = "SM-A365-LCD", 
                    Brand = "Samsung", 
                    Model = "Galaxy A36", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 8, 
                    CreatedAt = fixedDate 
                },
                new Part 
                { 
                    Id = 9, 
                    Name = "Samsung Galaxy A56 Charging Port", 
                    Description = "USB-C charging port for Galaxy A56", 
                    Price = 39.99m, 
                    CostPrice = 20.00m, 
                    StockQuantity = 40, 
                    MinimumStockLevel = 12, 
                    SKU = "SAMSUNG-A56-USB", 
                    PartNumber = "SM-A565-USB", 
                    Brand = "Samsung", 
                    Model = "Galaxy A56", 
                    Condition = "OEM", 
                    Grade = "A", 
                    IsActive = true, 
                    IsOEM = true, 
                    PartCategoryId = 3, 
                    CreatedAt = fixedDate 
                }
            );

            // Seed Part Compatibilities
            modelBuilder.Entity<PartCompatibility>().HasData(
                new PartCompatibility { Id = 1, PartId = 1, PhoneModelId = 1, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 2, PartId = 2, PhoneModelId = 1, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 3, PartId = 3, PhoneModelId = 3, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 4, PartId = 4, PhoneModelId = 1, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 5, PartId = 5, PhoneModelId = 3, IsVerified = true, CreatedAt = fixedDate },
                // Xiaomi Redmi Note Series Part Compatibilities
                new PartCompatibility { Id = 6, PartId = 6, PhoneModelId = 5, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 7, PartId = 7, PhoneModelId = 6, IsVerified = true, CreatedAt = fixedDate },
                // Samsung Galaxy A Series Part Compatibilities
                new PartCompatibility { Id = 8, PartId = 8, PhoneModelId = 8, IsVerified = true, CreatedAt = fixedDate },
                new PartCompatibility { Id = 9, PartId = 9, PhoneModelId = 9, IsVerified = true, CreatedAt = fixedDate }
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
                    PhoneModelId = 4, 
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
                    Name = "Xiaomi Redmi Note 11 Pro - Battery Replacement", 
                    Description = "Battery replacement for Redmi Note 11 Pro", 
                    ServiceFee = 120.00m, 
                    EstimatedDuration = 1.5m, 
                    Status = "Pending", 
                    UserId = 1, 
                    PhoneModelId = 5, 
                    CreatedAt = fixedDate 
                }
            );

        }


    }
} 