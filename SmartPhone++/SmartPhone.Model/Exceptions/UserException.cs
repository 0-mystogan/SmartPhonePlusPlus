using System;

namespace SmartPhone.Model
{
    public class UserException : Exception
    {
        public UserException(string message) : base(message) { }
        public UserException(string message, Exception inner) : base(message, inner) { }
    }
}
