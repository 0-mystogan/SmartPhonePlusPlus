using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using EasyNetQ;

namespace SmartPhone.Services.Services
{
    public class ServiceService : BaseCRUDService<ServiceResponse, ServiceSearchObject, Service, ServiceUpsertRequest, ServiceUpsertRequest>, IServiceService
    {
        public ServiceService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper) { }

        protected override IQueryable<Service> ApplyFilter(IQueryable<Service> query, ServiceSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(s => s.Name.Contains(search.Name));
            if (!string.IsNullOrEmpty(search.Status))
                query = query.Where(s => s.Status == search.Status);
            return query;
        }

        protected override Service MapInsertToEntity(Service entity, ServiceUpsertRequest request)
        {
            _mapper.Map(request, entity);
            
            // Set additional properties after mapping
            entity.Status = "Pending";
            entity.CreatedAt = DateTime.UtcNow;
            entity.UpdatedAt = DateTime.UtcNow;
            
            // Convert double to decimal for database storage
            entity.ServiceFee = (decimal)request.ServiceFee;
            entity.EstimatedDuration = request.EstimatedDuration.HasValue ? (decimal)request.EstimatedDuration.Value : null;
            
            return entity;
        }

        protected override void MapUpdateToEntity(Service entity, ServiceUpsertRequest request)
        {
            _mapper.Map(request, entity);
            
            // Set additional properties after mapping
            entity.UpdatedAt = DateTime.UtcNow;
            
            // Convert double to decimal for database storage
            entity.ServiceFee = (decimal)request.ServiceFee;
            entity.EstimatedDuration = request.EstimatedDuration.HasValue ? (decimal)request.EstimatedDuration.Value : null;
        }

        public async Task<ServiceResponse> CompleteAsync(int id)
        {
            var entity = await _context.Services.FindAsync(id);
            if (entity == null)
                throw new Exception("Service not found");
            entity.Status = "Complete";
            await _context.SaveChangesAsync();

            // Get admin emails
            var adminEmails = await _context.Users
                .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Administrator"))
                .Select(u => u.Email)
                .ToListAsync();

            // Send RabbitMQ notification
            var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
            var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
            var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
            var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";
            var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

            var notificationDto = new SmartPhone.Subscriber.Models.ServiceNotificationDto
            {
                ServiceName = entity.Name,
                Status = entity.Status,
                AdminEmails = adminEmails
            };
            var serviceNotification = new SmartPhone.Subscriber.Models.ServiceNotification
            {
                Service = notificationDto
            };
            await bus.PubSub.PublishAsync(serviceNotification);

            return _mapper.Map<ServiceResponse>(entity);
        }
    }
} 