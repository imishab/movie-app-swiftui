import Foundation

protocol APIClientProtocol {

    func request<T: Decodable>(
        endpoint: Endpoint
    ) async throws -> T
}

final class APIClient: APIClientProtocol {

    func request<T: Decodable>(
        endpoint: Endpoint
    ) async throws -> T {

        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        let (data, response) =
        try await URLSession.shared.data(
            from: url
        )

        guard let response =
                response as? HTTPURLResponse,
              200...299 ~= response.statusCode
        else {
            throw NetworkError.invalidResponse
        }

        do {

            return try JSONDecoder().decode(
                T.self,
                from: data
            )

        } catch {

            throw NetworkError.decodingError
        }
    }
}