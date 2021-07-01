defmodule InBeautyWeb.CategoriesComponent do
  use InBeautyWeb, :live_component

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
      <div
        x-show="open"
        x-transition:enter="transition ease-out duration-150"
        x-transition:enter-start="transform -translate-y-full"
        x-transition:enter-end="transform"
        x-transition:leave="transition ease-in duration-75"
        x-transition:leave-start="transform"
        x-transition:leave-end="transform -translate-y-full"
        class="fixed min-w-screen min-h-screen inset-0 bg-gray-900 overflow-auto z-50"
      >
        <div class="px-2 pt-2 pb-4 rounded-md shadow-lg dark:bg-gray-700">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <p @click="open = !open" class="text-sm">XXX</p>
            <a class="flex row items-start rounded-lg bg-transparent p-2 dark:hover:bg-gray-600 dark:focus:bg-gray-600 dark:focus:text-white dark:hover:text-white dark:text-gray-200 hover:text-gray-900 focus:text-gray-900 hover:bg-gray-200 focus:bg-gray-200 focus:outline-none focus:shadow-outline" href="#">
              <div class="bg-teal-500 text-white rounded-lg p-3">
                <svg fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" class="md:h-6 md:w-6 h-4 w-4"><path d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"></path></svg>
              </div>
              <div class="ml-3">
                <p class="font-semibold">Appearance</p>
                <p class="text-sm">Easy customization</p>
              </div>
            </a>
            <a class="flex row items-start rounded-lg bg-transparent p-2 dark:hover:bg-gray-600 dark:focus:bg-gray-600 dark:focus:text-white dark:hover:text-white dark:text-gray-200 hover:text-gray-900 focus:text-gray-900 hover:bg-gray-200 focus:bg-gray-200 focus:outline-none focus:shadow-outline" href="#">
              <div class="bg-teal-500 text-white rounded-lg p-3">
                <svg fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" class="md:h-6 md:w-6 h-4 w-4"><path d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path></svg>
              </div>
              <div class="ml-3">
                <p class="font-semibold">Comments</p>
                <p class="text-sm">Check your latest comments</p>
              </div>
            </a>
            <a class="flex row items-start rounded-lg bg-transparent p-2 dark:hover:bg-gray-600 dark:focus:bg-gray-600 dark:focus:text-white dark:hover:text-white dark:text-gray-200 hover:text-gray-900 focus:text-gray-900 hover:bg-gray-200 focus:bg-gray-200 focus:outline-none focus:shadow-outline" href="#">
              <div class="bg-teal-500 text-white rounded-lg p-3">
                <svg fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" class="md:h-6 md:w-6 h-4 w-4"><path d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z"></path><path d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z"></path></svg>
              </div>
              <div class="ml-3">
                <p class="font-semibold">Analytics</p>
                <p class="text-sm">Take a look at your statistics</p>
              </div>
            </a>
          </div>
        </div>
      </div>
    """
  end
end
