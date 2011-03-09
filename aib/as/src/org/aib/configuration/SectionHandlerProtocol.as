/* See LICENSE for copyright and terms of use */

/**
 * Defines the interface that should be implemented by all section handlers
 * defined in the configuration file.
 *
 * @author Scott Hyndman
 */
interface org.aib.configuration.SectionHandlerProtocol
{	
	/**
	 * Parses the information contained within the passed XMLNode object.
	 */
	function initWithSectionNode(node:XMLNode):SectionHandlerProtocol;
}