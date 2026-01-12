/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: 'My Site',
  tagline: 'The tagline of my site',
  url: 'https://blog.anhvlt.io.vn',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'VLTA', // Usually your GitHub org/user name.
  projectName: 'docusaurus', // Usually your repo name.
  themeConfig: {
    navbar: {
      title: "VLTA's Blog",
      logo: {
        alt: 'My Site Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          to: 'docs/',
          activeBasePath: 'docs',
          label: 'Docs',
          position: 'left',
        },
        {
          to: 'blog', 
          label: 'Blog', 
          position: 'left'
        },
        {
          href: 'https://github.com/anhvlttfs',
          label: 'My GitHub Profile',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Contact me!',
          items: [
            {
              label: 'LinkedIn',
              href: 'https://www.linkedin.com/in/anhvlttfs/',
            },
            {
              label: 'YouTube',
              href: 'https://www.youtube.com/@anhvlttfs',
            },
            {
              label: 'Hugging Face',
              href: 'https://huggingface.co/anhvlt-2k6',
            },
            {
              label: 'Coursera',
              href: 'https://www.coursera.org/learner/anhvlttfs',
            },
            {
              label: 'Leetcode',
              href: 'https://leetcode.com/u/anhvlttfs/',
            },
            {
              label: 'Hacker Rank',
              href: 'https://www.hackerrank.com/profile/anhvlttfs',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'CASIO Calculator online',
              href: 'https://classpad.anhvlt.io.vn/',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/anhvlttfs',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Vo Luu Tuong Anh. Built with Docusaurus.`,
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl:
            'https://github.com/anhvlttfs/blog',
        },
        blog: {
          showReadingTime: true,
          editUrl:
            'https://github.com/anhvlttfs/blog/blob/master/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
