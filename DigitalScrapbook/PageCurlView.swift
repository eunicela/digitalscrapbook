import SwiftUI
import UIKit

struct PageCurlView<PageContent: View>: UIViewControllerRepresentable {
    var pages: [ScrapbookPage]
    @Binding var currentIndex: Int
    let content: (ScrapbookPage) -> PageContent

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal
        )
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        context.coordinator.reloadControllers()

        if let first = context.coordinator.controller(at: currentIndex) {
            controller.setViewControllers([first], direction: .forward, animated: false)
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        context.coordinator.reloadControllers()

        guard let visible = context.coordinator.controller(at: currentIndex) else {
            return
        }

        if uiViewController.viewControllers?.first !== visible {
            uiViewController.setViewControllers([visible], direction: .forward, animated: false)
        }
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageCurlView
        private var controllers: [UIViewController] = []

        init(_ parent: PageCurlView) {
            self.parent = parent
        }

        func reloadControllers() {
            controllers = parent.pages.map { page in
                UIHostingController(rootView: parent.content(page))
            }
        }

        func controller(at index: Int) -> UIViewController? {
            guard controllers.indices.contains(index) else {
                return nil
            }
            return controllers[index]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard
                let index = controllers.firstIndex(of: viewController),
                index > 0
            else {
                return nil
            }
            return controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard
                let index = controllers.firstIndex(of: viewController),
                index + 1 < controllers.count
            else {
                return nil
            }
            return controllers[index + 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard
                completed,
                let visible = pageViewController.viewControllers?.first,
                let index = controllers.firstIndex(of: visible)
            else {
                return
            }
            parent.currentIndex = index
        }
    }
}
