using SmartPhone.Services.Database;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.OpenApi.Models;
using SmartPhone.WebAPI.Filters;
using SmartPhone.Services.Services;
using SmartPhone.Services.Interfaces;
using System.Reflection;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.WebAPI.Mapping;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IGenderService, GenderService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IServiceService, ServiceService>();

// Parts Management Services
builder.Services.AddTransient<IPartCategoryService, PartCategoryService>();
builder.Services.AddTransient<IPartService, PartService>();
builder.Services.AddTransient<IPhoneModelService, PhoneModelService>();
builder.Services.AddTransient<IPartCompatibilityService, PartCompatibilityService>();
builder.Services.AddTransient<IServicePartService, ServicePartService>();

// eCommerce Services
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IProductService, ProductService>();
//builder.Services.AddTransient<IChatService, ChatService>();

// State Machine


// Configure database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=.;Database=SmartPhone++Db;User Id=sa;Password=QWEasd123!;TrustServerCertificate=True;Trusted_Connection=True;";
builder.Services.AddDatabaseServices(connectionString);

// Add configuration
builder.Services.AddSingleton<IConfiguration>(builder.Configuration);

builder.Services.AddMapster();

// Configure Mapster mappings
MappingConfig.ConfigureMappings();

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddControllers(x =>
    {
        x.Filters.Add<ExceptionFilter>();
    }
);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();

// Za dodavanje opisnog teksta pored swagger call-a
var xmlFilename = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";

builder.Services.AddSwaggerGen(c =>
{
    c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, xmlFilename));

    c.AddSecurityDefinition("BasicAuthentication", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Bearer scheme."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "BasicAuthentication" } },
            new string[] { }
        }
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<SmartPhoneDbContext>();


    var pendingMigrations = dataContext.Database.GetPendingMigrations().Any();

    if (pendingMigrations)
    {
        dataContext.Database.Migrate();
    }
}

app.Run();
 