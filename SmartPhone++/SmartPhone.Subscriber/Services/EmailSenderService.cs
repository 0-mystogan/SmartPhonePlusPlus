using System.Net;
using System.Net.Mail;
using SmartPhone.Subscriber.Interfaces;

namespace SmartPhone.Subscriber.Services
{
    public class EmailSenderService : IEmailSenderService
    {
        private readonly string _gmailMail = "smartphoneplusplus.sender@gmail.com";
        private readonly string _gmailPass = "cyse rydn gaxc kiwb";

        public Task SendEmailAsync(string email, string subject, string message)
        {
            var client = new SmtpClient("smtp.gmail.com", 587)
            {
                EnableSsl = true,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(_gmailMail, _gmailPass)
            };

            return client.SendMailAsync(
                new MailMessage(from: _gmailMail,
                              to: email,
                              subject,
                              message
                              ));
        }
    }
}