import Foundation
import Testing
@testable import AI课堂

@MainActor
struct BackendP0IntegrationTests {
    @Test
    func bootstrapResponseMapsToClientConfiguration() throws {
        let json = """
        {
          "appName": "AI课堂",
          "userNickname": "小小创作者",
          "aiFriends": [
            {
              "id": "30000000-0000-0000-0000-000000000001",
              "name": "故事伙伴",
              "icon": "book.closed.fill",
              "description": "一起创作适合孩子的故事",
              "rolePrompt": "你是温和的儿童故事伙伴。",
              "status": "ACTIVE"
            }
          ],
          "creationCards": [
            {
              "id": "40000000-0000-0000-0000-000000000001",
              "type": "story",
              "name": "故事卡",
              "icon": "book.fill",
              "promptTemplate": "根据种子、主题、价值和风格生成故事。",
              "status": "ACTIVE"
            }
          ],
          "parentControl": {
            "computeBudgetLimit": 100,
            "dailyMinutesLimit": 60,
            "allowPublicPublishing": true,
            "autoNarrationEnabled": true,
            "voiceInputEnabled": true
          }
        }
        """

        let payload = try JSONDecoder().decode(AppBootstrapDTO.self, from: Data(json.utf8))
        let configuration = payload.clientConfiguration()

        #expect(configuration.friends.map(\.name) == ["故事伙伴"])
        #expect(configuration.friends.first?.emoji == "📚")
        #expect(configuration.friends.first?.isClassroomAssigned == true)
        #expect(configuration.creationTypes.map(\.kind) == [.story])
        #expect(configuration.parentSettings.dailyMinutesLimit == 60)
    }

    @Test
    func adminWorksResponseMapsPublishedItemsToPlazaProjects() throws {
        let json = """
        {
          "items": [
            {
              "id": "50000000-0000-0000-0000-000000000001",
              "type": "story",
              "title": "小鹿的发光地图",
              "authorName": "学生A",
              "status": "PUBLISHED",
              "published": true,
              "recommended": false,
              "likeCount": 8,
              "score": 4.8
            },
            {
              "id": "50000000-0000-0000-0000-000000000002",
              "type": "drawing",
              "title": "待审核图画",
              "authorName": "学生B",
              "status": "PENDING_REVIEW",
              "published": false,
              "recommended": false,
              "likeCount": 0,
              "score": 0
            }
          ],
          "page": 1,
          "pageSize": 20,
          "total": 2
        }
        """

        let payload = try JSONDecoder().decode(PageDTO<BackendWorkDTO>.self, from: Data(json.utf8))
        let projects = payload.items.compactMap(\.plazaProject)

        #expect(projects.count == 1)
        #expect(projects.first?.title == "小鹿的发光地图")
        #expect(projects.first?.status == .published)
        #expect(projects.first?.likeCount == 8)
        #expect(projects.first?.rating == 4.8)
    }
}
