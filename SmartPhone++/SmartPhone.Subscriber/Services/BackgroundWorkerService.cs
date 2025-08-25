using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Versioning;
using System.Linq;
using SmartPhone.Subscriber.Models;
using SmartPhone.Subscriber.Interfaces;
using System.Net.Sockets;
using System.Net;

namespace SmartPhone.Subscriber.Services
{
    public class BackgroundWorkerService : BackgroundService
    {
        private readonly ILogger<BackgroundWorkerService> _logger;
        private readonly IEmailSenderService _emailSender;
        private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
        private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
        private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
        private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

        public BackgroundWorkerService(
            ILogger<BackgroundWorkerService> logger,
            IEmailSenderService emailSender)
        {
            _logger = logger;
            _emailSender = emailSender;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            // Check internet connectivity to smtp.gmail.com
            try
            {
                var addresses = await Dns.GetHostAddressesAsync("smtp.gmail.com");
                _logger.LogInformation($"smtp.gmail.com resolved to: {string.Join(", ", addresses.Select(a => a.ToString()))}");
                using (var client = new TcpClient())
                {
                    var connectTask = client.ConnectAsync("smtp.gmail.com", 587);
                    var timeoutTask = Task.Delay(5000, stoppingToken);
                    var completed = await Task.WhenAny(connectTask, timeoutTask);
                    if (completed == connectTask && client.Connected)
                    {
                        _logger.LogInformation("Successfully connected to smtp.gmail.com:587");
                    }
                    else
                    {
                        _logger.LogError("Failed to connect to smtp.gmail.com:587 (timeout or error)");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Internet connectivity check failed: {ex.Message}");
            }

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var bus = RabbitHutch.CreateBus($"host={_host};virtualHost={_virtualhost};username={_username};password={_password}"))
                    {
                        // Subscribe to service notifications only
                        bus.PubSub.Subscribe<ServiceNotification>("Service_Notifications", HandleServiceMessage);

                        _logger.LogInformation("Waiting for service notifications...");
                        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                    }
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error in RabbitMQ listener: {ex.Message}");
                }
            }
        }

        private async Task HandleServiceMessage(ServiceNotification notification)
        {
            var service = notification.Service;
            if (service?.CustomerEmail == null || string.IsNullOrEmpty(service.CustomerEmail))
            {
                _logger.LogWarning("No customer email provided in the service notification");
                return;
            }

            var subject = $"Your Phone Service is Ready for Pickup - {service.ServiceName}";
            var message = BuildCustomerNotificationMessage(service);
            
            try
            {
                await _emailSender.SendEmailAsync(service.CustomerEmail, subject, message);
                _logger.LogInformation($"Service completion notification sent to customer: {service.CustomerEmail} for service: {service.ServiceName}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send service completion email to customer {service.CustomerEmail}: {ex.Message}");
            }
        }

        private string BuildCustomerNotificationMessage(ServiceNotificationDto service)
        {
            var message = $@"Dear {service.CustomerName},

We're pleased to inform you that your phone service has been completed!

Service Details:
- Service: {service.ServiceName}
- Status: {service.Status}";

            if (!string.IsNullOrEmpty(service.PhoneModel))
            {
                message += $@"
- Phone Model: {service.PhoneModel}";
            }

            message += $@"

Your device is now ready for pickup. Please visit our service center during business hours to collect your phone.

Thank you for choosing SmartPhone++ for your device repair needs!

Best regards,
SmartPhone++ Service Team";

            return message;
        }
    }
}