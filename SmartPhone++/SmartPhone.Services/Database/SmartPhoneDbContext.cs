using Microsoft.EntityFrameworkCore;

namespace SmartPhone.Services.Database
{
    public class SmartPhoneDbContext : DbContext
    {
        public SmartPhoneDbContext(DbContextOptions<SmartPhoneDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Gender> Genders { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Service> Services { get; set; }
        
        // eCommerce entities
        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<ProductImage> ProductImages { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<Cart> Carts { get; set; }
        public DbSet<CartItem> CartItems { get; set; }
        
        // Parts Management entities
        public DbSet<PartCategory> PartCategories { get; set; }
        public DbSet<Part> Parts { get; set; }
        public DbSet<PhoneModel> PhoneModels { get; set; }
        public DbSet<PartCompatibility> PartCompatibilities { get; set; }
        public DbSet<ServicePart> ServiceParts { get; set; }

    

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();
               

            // Configure Role entity
            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            // Configure UserRole join entity
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on UserId and RoleId
            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();


            // Configure Gender entity
            modelBuilder.Entity<Gender>()
                .HasIndex(g => g.Name)
                .IsUnique();

            // Configure City entity
            modelBuilder.Entity<City>()
                .HasIndex(c => c.Name)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasOne(u => u.Gender)
                .WithMany()
                .HasForeignKey(u => u.GenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasOne(u => u.City)
                .WithMany()
                .HasForeignKey(u => u.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure eCommerce entities
            
            // Category self-referencing relationship
            modelBuilder.Entity<Category>()
                .HasOne(c => c.ParentCategory)
                .WithMany(c => c.SubCategories)
                .HasForeignKey(c => c.ParentCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Category>()
                .HasIndex(c => c.Name)
                .IsUnique();

            // Product configurations
            modelBuilder.Entity<Product>()
                .HasOne(p => p.Category)
                .WithMany(c => c.Products)
                .HasForeignKey(p => p.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Product>()
                .HasIndex(p => p.SKU)
                .IsUnique();

            modelBuilder.Entity<Product>()
                .HasIndex(p => p.Name);

            // ProductImage configurations
            modelBuilder.Entity<ProductImage>()
                .HasOne(pi => pi.Product)
                .WithMany(p => p.ProductImages)
                .HasForeignKey(pi => pi.ProductId)
                .OnDelete(DeleteBehavior.Cascade);

            // Order configurations
            modelBuilder.Entity<Order>()
                .HasOne(o => o.User)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Order>()
                .HasIndex(o => o.OrderNumber)
                .IsUnique();

            // OrderItem configurations
            modelBuilder.Entity<OrderItem>()
                .HasOne(oi => oi.Order)
                .WithMany(o => o.OrderItems)
                .HasForeignKey(oi => oi.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<OrderItem>()
                .HasOne(oi => oi.Product)
                .WithMany(p => p.OrderItems)
                .HasForeignKey(oi => oi.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // Cart configurations
            modelBuilder.Entity<Cart>()
                .HasOne(c => c.User)
                .WithMany(u => u.Carts)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // CartItem configurations
            modelBuilder.Entity<CartItem>()
                .HasOne(ci => ci.Cart)
                .WithMany(c => c.CartItems)
                .HasForeignKey(ci => ci.CartId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<CartItem>()
                .HasOne(ci => ci.Product)
                .WithMany(p => p.CartItems)
                .HasForeignKey(ci => ci.ProductId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Parts Management entities
            
            // PartCategory self-referencing relationship
            modelBuilder.Entity<PartCategory>()
                .HasOne(pc => pc.ParentCategory)
                .WithMany(pc => pc.SubCategories)
                .HasForeignKey(pc => pc.ParentCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PartCategory>()
                .HasIndex(pc => pc.Name)
                .IsUnique();

            // Part configurations
            modelBuilder.Entity<Part>()
                .HasOne(p => p.PartCategory)
                .WithMany(pc => pc.Parts)
                .HasForeignKey(p => p.PartCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Part>()
                .HasIndex(p => p.SKU)
                .IsUnique();

            modelBuilder.Entity<Part>()
                .HasIndex(p => p.PartNumber);

            modelBuilder.Entity<Part>()
                .HasIndex(p => p.Brand);

            // PhoneModel configurations
            modelBuilder.Entity<PhoneModel>()
                .HasIndex(pm => new { pm.Brand, pm.Model, pm.Storage })
                .IsUnique();

            modelBuilder.Entity<PhoneModel>()
                .HasIndex(pm => pm.Brand);

            // PartCompatibility configurations
            modelBuilder.Entity<PartCompatibility>()
                .HasOne(pc => pc.Part)
                .WithMany(p => p.CompatiblePhones)
                .HasForeignKey(pc => pc.PartId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PartCompatibility>()
                .HasOne(pc => pc.PhoneModel)
                .WithMany(pm => pm.CompatibleParts)
                .HasForeignKey(pc => pc.PhoneModelId)
                .OnDelete(DeleteBehavior.Cascade);

            // Ensure unique part-phone compatibility
            modelBuilder.Entity<PartCompatibility>()
                .HasIndex(pc => new { pc.PartId, pc.PhoneModelId })
                .IsUnique();

            // Service configurations
            modelBuilder.Entity<Service>()
                .HasOne(s => s.User)
                .WithMany(u => u.CustomerServices)
                .HasForeignKey(s => s.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Service>()
                .HasOne(s => s.Technician)
                .WithMany(u => u.TechnicianServices)
                .HasForeignKey(s => s.TechnicianId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<Service>()
                .HasOne(s => s.PhoneModel)
                .WithMany(pm => pm.Services)
                .HasForeignKey(s => s.PhoneModelId)
                .OnDelete(DeleteBehavior.SetNull);

            // ServicePart configurations
            modelBuilder.Entity<ServicePart>()
                .HasOne(sp => sp.Service)
                .WithMany(s => s.ServiceParts)
                .HasForeignKey(sp => sp.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ServicePart>()
                .HasOne(sp => sp.Part)
                .WithMany(p => p.ServiceParts)
                .HasForeignKey(sp => sp.PartId)
                .OnDelete(DeleteBehavior.Restrict);

            // Seed initial data
            modelBuilder.SeedData();
        }
    }
} 