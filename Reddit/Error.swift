enum Error: ErrorType
{
    case MissingJsonProperty(name: String)
    case NetworkError(message: String?)
    case UnexpectedStatusCode(code: Int)
    case MissingData
    case InvalidJsonData
}