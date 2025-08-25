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
            var entity = await _context.Services
                .Include(s => s.User) // Include customer information
                .Include(s => s.PhoneModel) // Include phone model information
                .FirstOrDefaultAsync(s => s.Id == id);
            
            if (entity == null)
                throw new Exception("Service not found");
            
            entity.Status = "Complete";
            entity.CompletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            // Send RabbitMQ notification to customer
            var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
            var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
            var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
            var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";
            var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

            var notificationDto = new SmartPhone.Subscriber.Models.ServiceNotificationDto
            {
                ServiceName = entity.Name,
                Status = entity.Status,
                CustomerEmail = entity.User.Email,
                CustomerName = $"{entity.User.FirstName} {entity.User.LastName}".Trim(),
                PhoneModel = entity.PhoneModel != null 
                    ? $"{entity.PhoneModel.Brand} {entity.PhoneModel.Model}".Trim()
                    : null
            };
            var serviceNotification = new SmartPhone.Subscriber.Models.ServiceNotification
            {
                Service = notificationDto
            };
            await bus.PubSub.PublishAsync(serviceNotification);

            return _mapper.Map<ServiceResponse>(entity);
        }

        public async Task<ServiceInvoiceResponse> GetInvoiceAsync(int serviceId)
        {
            var entity = await _context.Services
                .Include(s => s.ServiceParts)
                    .ThenInclude(sp => sp.Part)
                .Include(s => s.User)
                .FirstOrDefaultAsync(s => s.Id == serviceId);

            if (entity == null)
            {
                throw new Exception("Service not found");
            }

            var invoice = new ServiceInvoiceResponse
            {
                InvoiceNumber = $"SRV-{entity.Id:0000}",
                Date = entity.CreatedAt,
                CustomerName = entity.User != null ? $"{entity.User.FirstName} {entity.User.LastName}".Trim() : "Unknown",
                Items = entity.ServiceParts.Select(sp => new ServiceInvoiceItemResponse
                {
                    Description = sp.Part != null ? sp.Part.Name : "Part",
                    Quantity = sp.Quantity,
                    UnitPrice = sp.UnitPrice
                }).ToList()
            };

            return invoice;
        }

        public async Task<ServiceVerificationResponse> GetVerificationAsync(int serviceId)
        {
            var entity = await _context.Services
                .Include(s => s.User)
                .Include(s => s.Technician)
                .FirstOrDefaultAsync(s => s.Id == serviceId);

            if (entity == null)
            {
                throw new Exception("Service not found");
            }

            DateTime? estimatedCompletion = null;
            if (entity.EstimatedDuration.HasValue)
            {
                // EstimatedDuration is in hours
                estimatedCompletion = entity.CreatedAt.AddHours((double)entity.EstimatedDuration.Value);
            }

            var verification = new ServiceVerificationResponse
            {
                ServiceId = entity.Id,
                Name = entity.Name,
                Description = entity.Description,
                ServiceFee = entity.ServiceFee,
                CustomerNotes = entity.CustomerNotes,
                CreatedAt = entity.CreatedAt,
                CustomerName = entity.User != null ? $"{entity.User.FirstName} {entity.User.LastName}".Trim() : "Unknown",
                TechnicianName = entity.Technician != null ? $"{entity.Technician.FirstName} {entity.Technician.LastName}".Trim() : null,
                EstimatedCompletion = estimatedCompletion
            };

            return verification;
        }
    }
} 