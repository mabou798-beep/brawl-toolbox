import '../models/news_post.dart';

/// Placeholder community feed. There is no public API for third-party Brawl
/// Stars forums, so this is local content styled like real forum posts.
/// Swap this list for a real RSS/REST call once you have a backend or feed
/// source to point at (e.g. a subreddit's public JSON feed, a Discord
/// webhook archive, or your own CMS).
const List<NewsPost> mockNewsPosts = [
  NewsPost(
    title: 'Weekly Meta Watch: what\'s strong in Gem Grab right now',
    summary:
        'A rundown of the brawler classes players are leaning on this week and why control of the mine matters more than raw damage.',
    body:
        'Gem Grab rewards map control over raw kills. Controllers and support brawlers that can hold the middle tend to swing games, '
        'since carrying 10 gems safely is worth more than a single elimination. If you\'re queueing solo, prioritize picks that can '
        'zone the mine rather than ones that just deal damage from range.',
    category: 'Guide',
    author: 'u/GemGrabGuru',
    timeAgo: '2h ago',
    upvotes: 214,
    comments: 38,
  ),
  NewsPost(
    title: 'Fan Art Friday: community spotlight',
    summary:
        'Every week the community shares brawler redesigns, comics and animations — here are the picks the mods pinned this round.',
    body:
        'Fan art threads are one of the most active corners of the community. If you want your work featured, tag it with the '
        'weekly megathread flair and include your brawler pick in the title — mods pull picks manually every Friday.',
    category: 'Fan Art',
    author: 'u/PixelBrawler',
    timeAgo: '5h ago',
    upvotes: 512,
    comments: 74,
  ),
  NewsPost(
    title: 'How to counter throwers without raging',
    summary:
        'Throwers can feel unfair up close. A quick primer on angles, walls, and the brawlers that close the gap safely.',
    body:
        'Throwers win by keeping you at range behind cover. The fix is almost always the same: use walls to break line of sight, '
        'approach from an angle they haven\'t warded, and pick brawlers with dashes or high mobility to close the distance fast.',
    category: 'Tips',
    author: 'u/CoachKit',
    timeAgo: '8h ago',
    upvotes: 189,
    comments: 22,
  ),
  NewsPost(
    title: 'Esports corner: reading a draft like a pro team',
    summary:
        'Bans matter more than first picks. Here\'s how competitive teams think about the first 30 seconds of a draft.',
    body:
        'Competitive drafts are won in the ban phase. Teams typically ban whatever removes the most flexibility from the opponent\'s '
        'comp, not just the single strongest brawler. Watching VODs with the ban phase in mind changes how you read every draft after.',
    category: 'Esports',
    author: 'u/DraftAnalyst',
    timeAgo: '1d ago',
    upvotes: 341,
    comments: 56,
  ),
  NewsPost(
    title: 'Brawl Talk watch party — community traditions',
    summary:
        'Official update reveals usually land as a video update from the developers. Here\'s how the community usually reacts and prepares.',
    body:
        'When a new update video drops, the community usually floods the megathread with reaction clips within minutes. If you want '
        'the calmest read on patch changes, wait a day for written recap threads instead of the first wave of hot takes.',
    category: 'Community',
    author: 'u/NewsBot',
    timeAgo: '1d ago',
    upvotes: 267,
    comments: 91,
  ),
  NewsPost(
    title: 'Underrated pick of the week',
    summary:
        'One brawler the ladder is sleeping on right now, and the game mode where they quietly outperform their pick rate.',
    body:
        'Low pick-rate brawlers often get overlooked simply because they\'re unfamiliar, not because they\'re weak. Spend a session in '
        'friendly-battle practicing one off-meta pick — you might find a niche where they\'re genuinely strong.',
    category: 'Guide',
    author: 'u/MetaDigger',
    timeAgo: '2d ago',
    upvotes: 156,
    comments: 19,
  ),
  NewsPost(
    title: 'Clan recruitment megathread etiquette',
    summary:
        'A short guide on how to post (and how not to post) when you\'re looking for a new clan or recruiting for yours.',
    body:
        'Recruitment posts do best with a clear trophy requirement, activity expectation, and time zone up front. Vague posts like '
        '"looking for active members" get scrolled past — specifics get replies.',
    category: 'Community',
    author: 'u/ClanMod',
    timeAgo: '2d ago',
    upvotes: 98,
    comments: 14,
  ),
  NewsPost(
    title: 'Map rotation strategy: adapting build to layout',
    summary:
        'The same brawler can feel completely different depending on how open or tight a map is. Here\'s what to look for.',
    body:
        'Wide open maps favor long-range poke, while tight corridor maps favor burst and area denial. Before locking a pick, glance at '
        'chokepoints and bush density — they matter more than raw brawler tier lists.',
    category: 'Tips',
    author: 'u/MapSense',
    timeAgo: '3d ago',
    upvotes: 133,
    comments: 27,
  ),
];
