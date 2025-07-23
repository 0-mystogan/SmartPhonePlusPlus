using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace SmartPhone.Services.Database
{
    public static class DatabaseConfiguration
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<SmartPhoneDbContext>(options =>
                options.UseSqlServer(connectionString));
        }

        public static void AddDatabaseSmartPhone(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<SmartPhoneDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
    }
}