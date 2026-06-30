import Foundation

protocol AppBackendClient {
    func sendLoginCode(phone: String) async throws
    func login(phone: String, code: String) async throws -> BackendLoginSession
    func fetchBootstrap() async throws -> AppBackendConfiguration
    func fetchWorks() async throws -> [BackendWorkDTO]
    func createWork(from project: CreationProject) async throws -> BackendWorkDTO
}

struct BackendLoginSession: Equatable {
    let token: String
    let role: String
    let displayName: String
}

struct AppBackendConfiguration: Equatable {
    let friends: [AIFriend]
    let creationTypes: [CreationType]
    let parentSettings: ParentSettings
}

enum AppBackendError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(Int)
    case emptyToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "后台地址无效"
        case .invalidResponse:
            return "后台返回格式无效"
        case let .requestFailed(statusCode):
            return "后台请求失败：\(statusCode)"
        case .emptyToken:
            return "尚未登录后台"
        }
    }
}

final class LiveAppBackendClient: AppBackendClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenStore: BackendTokenStore
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(
        baseURL: URL = AppBackendEnvironment.baseURL,
        session: URLSession = .shared,
        tokenStore: BackendTokenStore = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
    }

    func sendLoginCode(phone: String) async throws {
        let body = ["phone": phone]
        let _: EmptyMessageDTO = try await request(
            "/api/v1/auth/sms/send",
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }

    func login(phone: String, code: String) async throws -> BackendLoginSession {
        let dto: LoginResponseDTO = try await request(
            "/api/v1/auth/sms/login",
            method: "POST",
            body: LoginRequestDTO(phone: phone, code: code),
            requiresAuth: false
        )
        tokenStore.token = dto.token
        return BackendLoginSession(token: dto.token, role: dto.role, displayName: dto.displayName)
    }

    func fetchBootstrap() async throws -> AppBackendConfiguration {
        let dto: AppBootstrapDTO = try await request(
            "/api/v1/app/bootstrap",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: false
        )
        return dto.clientConfiguration()
    }

    func fetchWorks() async throws -> [BackendWorkDTO] {
        let page: PageDTO<BackendWorkDTO> = try await request(
            "/api/v1/admin/works",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: true
        )
        return page.items
    }

    func createWork(from project: CreationProject) async throws -> BackendWorkDTO {
        try await request(
            "/api/v1/admin/works",
            method: "POST",
            body: CreateBackendWorkRequest(project: project),
            requiresAuth: true
        )
    }

    private func request<Response: Decodable, Body: Encodable>(
        _ path: String,
        method: String,
        body: Body?,
        requiresAuth: Bool
    ) async throws -> Response {
        let payload: ApiResponseDTO<Response> = try await rawRequest(path, method: method, body: body, requiresAuth: requiresAuth)
        return payload.data
    }

    private func rawRequest<Response: Decodable, Body: Encodable>(
        _ path: String,
        method: String,
        body: Body?,
        requiresAuth: Bool
    ) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw AppBackendError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if requiresAuth {
            guard let token = tokenStore.token, !token.isEmpty else {
                throw AppBackendError.emptyToken
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppBackendError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw AppBackendError.requestFailed(httpResponse.statusCode)
        }

        return try decoder.decode(Response.self, from: data)
    }
}

enum AppBackendEnvironment {
    static let baseURL = URL(string: "http://127.0.0.1:8080")!
}

final class BackendTokenStore {
    static let shared = BackendTokenStore()

    private let defaults: UserDefaults
    private let tokenKey = "AIClassroom.backendToken"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var token: String? {
        get { defaults.string(forKey: tokenKey) }
        set { defaults.set(newValue, forKey: tokenKey) }
    }
}
