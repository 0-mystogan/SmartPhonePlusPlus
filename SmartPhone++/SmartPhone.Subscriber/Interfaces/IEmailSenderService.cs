using System.Threading.Tasks;

namespace SmartPhone.Subscriber.Interfaces
{
    public interface IEmailSenderService
    {
        Task SendEmailAsync(string email, string subject, string message);
    }
}
